#!/bin/sh
# Waybar VPN helper. Emits status JSON for the bar; `toggle` flips a provider
# without sudo and reports the outcome through a SwayNC notification.

set -u

TIMEOUT=4
ACTION_TIMEOUT=60
STATE_TIMEOUT=15

provider_state() {
	json=
	if ! command -v "$1" >/dev/null 2>&1; then
		state='Not installed'
		return
	fi
	json=$(timeout "$TIMEOUT" "$1" status --json 2>/dev/null) || {
		state=Unavailable
		return
	}
	case $1 in
	netbird)
		mgmt=$(printf '%s' "$json" | jq -r '.management.connected')
		sig=$(printf '%s' "$json" | jq -r '.signal.connected')
		if [ "$mgmt" = null ] || [ "$sig" = null ]; then
			state=Unavailable
		elif [ "$mgmt" = true ] && [ "$sig" = true ]; then
			state=Connected
		else
			state=Disconnected
		fi
		;;
	tailscale)
		case $(printf '%s' "$json" | jq -r '.BackendState // empty') in
		Running) state=Connected ;;
		Stopped) state=Disconnected ;;
		NeedsLogin) state='Sign in required' ;;
		NeedsMachineAuth) state='Approval required' ;;
		Starting) state=Connecting ;;
		*) state=Unavailable ;;
		esac
		;;
	esac
}

tailscale_exit_node() {
	printf '%s' "$json" | jq -r '
		(.ExitNodeStatus.ID // empty) as $id
		| if $id == "" then empty else
			([.Peer[]? | select(.ID == $id)][0]) as $peer
			| [
				(($peer.HostName // $peer.DNSName // $id) | rtrimstr(".")),
				([.ExitNodeStatus.TailscaleIPs[]?, $peer.TailscaleIPs[]?]
					| map(select(test("^[0-9]+\\.")))[0] // ""
					| split("/")[0])
			]
			| @tsv
		end'
}

# Coordination server host: Tailscale's control URL (e.g. a self-hosted
# Headscale) or NetBird's management URL.
provider_server() {
	case $1 in
	netbird) printf '%s' "$json" | jq -r '.management.url // empty' ;;
	tailscale) timeout "$TIMEOUT" tailscale debug prefs 2>/dev/null | jq -r '.ControlURL // empty' ;;
	esac | sed -E 's#^[a-z]+://##; s#[:/].*##'
}

interface_ipv4() {
	ip -4 -o address show dev "$1" 2>/dev/null |
		awk 'NR == 1 { split($4, address, "/"); print address[1] }'
}

notify() { # $1 summary  $2 body  $3 urgency (default normal)
	notify-send -a VPN -i "$icon" -u "${3:-normal}" "$1" "$2"
}

toggle() {
	icon="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/$1.svg"
	case $1 in
	netbird) name=NetBird ;;
	*) name=Tailscale ;;
	esac
	provider_state "$1"
	case $state in
	'Not installed')
		notify "$name" 'Not installed' critical
		return
		;;
	Unavailable)
		notify "$name" 'Unavailable — is the daemon running?' critical
		return
		;;
	Connected)
		action=down
		label=Disconnected
		;;
	*)
		action=up
		label=Connected
		;;
	esac
	out=$(timeout "$ACTION_TIMEOUT" "$1" "$action" 2>&1)
	rc=$?
	if [ "$rc" -eq 0 ]; then
		deadline=$(( $(date +%s) + STATE_TIMEOUT ))
		while :; do
			provider_state "$1"
			if [ "$state" = "$label" ]; then
				notify "$name" "$label"
				return
			fi
			if [ "$(date +%s)" -ge "$deadline" ]; then
				break
			fi
			sleep 1
		done
		notify "$name" "$action completed, but status is $state. Check $1 status for details." critical
	else
		reason=$(printf '%s' "$out" | head -n 1)
		if [ "$rc" -eq 124 ]; then
			notify "$name" "Timed out after ${ACTION_TIMEOUT}s${reason:+: $reason}" critical
		else
			notify "$name" "$action failed: ${reason:-exit $rc}" critical
		fi
	fi
}

status_json() {
	provider_state netbird
	nb=$state
	nb_server=$(provider_server netbird)
	provider_state tailscale
	ts=$state
	ts_server=$(provider_server tailscale)
	ts_exit=$(tailscale_exit_node)
	nb_ip=$(interface_ipv4 wt0)
	ts_ip=$(interface_ipv4 tailscale0)
	nb_detail="${nb}${nb_server:+ · $nb_server}${nb_ip:+ · $nb_ip}"
	ts_detail="${ts}${ts_server:+ · $ts_server}${ts_ip:+ · $ts_ip}"
	nb_row="NetBird: ${nb}${nb_server:+ · $nb_server}"
	ts_row="Tailscale: ${ts}${ts_server:+ · $ts_server}"
	if [ -n "$ts_exit" ]; then
		IFS="	" read -r ts_exit_name ts_exit_ip <<EOF
$ts_exit
EOF
		ts_detail="${ts_detail} · Exit: ${ts_exit_name}${ts_exit_ip:+ · $ts_exit_ip}"
		ts_row="${ts_row} · Exit: ${ts_exit_name}"
	fi
	text=
	class=disconnected
	case $nb in Connected) text=NetBird ;; esac
	case $ts in Connected) text="${text:+$text, }Tailscale" ;; esac
	case $nb$ts in
	*Connected*) class=connected ;;
	*Unavailable*) class=error ;;
	esac
	# Waybar ignores `rows`; the rofi VPN menu uses them as its entries.
	status=$(jq -cn --arg text "$text" --arg class "$class" \
		--arg nb "$nb_detail" --arg ts "$ts_detail" --arg nb_row "$nb_row" --arg ts_row "$ts_row" \
		'{text: $text, alt: $class, class: $class,
			tooltip: "NetBird: \($nb)\nTailscale: \($ts)\n\nClick to manage VPN connections",
			rows: [$nb_row, $ts_row]}')
	if [ -n "${XDG_RUNTIME_DIR:-}" ] && cache_tmp=$(mktemp "$XDG_RUNTIME_DIR/super-rofi-vpn.json.XXXXXX"); then
		printf '%s\n' "$status" > "$cache_tmp"
		mv "$cache_tmp" "$XDG_RUNTIME_DIR/super-rofi-vpn.json"
	fi
	printf '%s\n' "$status"
}

case ${1:-} in
'') status_json ;;
netbird | tailscale)
	if [ "${2:-}" != toggle ]; then
		printf 'Usage: vpn.sh [netbird|tailscale toggle]\n' >&2
		exit 2
	fi
	toggle "$1"
	;;
*)
	printf 'Usage: vpn.sh [netbird|tailscale toggle]\n' >&2
	exit 2
	;;
esac
