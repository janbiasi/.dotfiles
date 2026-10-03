#!/bin/sh
# Waybar VPN helper. Emits status JSON for the bar; `toggle` flips a provider
# without sudo and reports the outcome through a SwayNC notification.

set -u

TIMEOUT=4
ACTION_TIMEOUT=60

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

interface_ipv4() {
	ip -4 -o address show dev "$1" 2>/dev/null |
		awk 'NR == 1 { split($4, address, "/"); print address[1] }'
}

notify() { # $1 summary  $2 body  $3 urgency (default normal)
	notify-send -a VPN -u "${3:-normal}" "$1" "$2"
}

toggle() {
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
		notify "$name" "$label"
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
	provider_state tailscale
	ts=$state
	ts_exit=$(tailscale_exit_node)
	nb_ip=$(interface_ipv4 wt0)
	ts_ip=$(interface_ipv4 tailscale0)
	nb_detail="${nb}${nb_ip:+ · $nb_ip}"
	ts_detail="${ts}${ts_ip:+ · $ts_ip}"
	if [ -n "$ts_exit" ]; then
		IFS="	" read -r ts_exit_name ts_exit_ip <<EOF
$ts_exit
EOF
		ts_detail="${ts_detail} · Exit: ${ts_exit_name}${ts_exit_ip:+ · $ts_exit_ip}"
	fi
	text=
	class=disconnected
	case $nb in Connected) text=NetBird ;; esac
	case $ts in Connected) text="${text:+$text, }Tailscale" ;; esac
	case $nb$ts in
	*Connected*) class=connected ;;
	*Unavailable*) class=error ;;
	esac
	status=$(printf '{"text": "%s", "alt": "%s", "class": "%s", "tooltip": "NetBird: %s\\nTailscale: %s\\n\\nClick to manage VPN connections"}' \
		"$text" "$class" "$class" "$nb_detail" "$ts_detail")
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
