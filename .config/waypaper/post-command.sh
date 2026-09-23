#!/usr/bin/env bash
set -u

failures=0

run_step() {
  local label=$1
  local status
  shift

  if "$@"; then
    return
  else
    status=$?
  fi

  printf 'Waypaper: %s failed (exit %s)\n' "$label" "$status" >&2
  notify-send --app-name=Waypaper --urgency=critical \
    'Wallpaper theme update failed' "$label failed (exit $status)" || \
    printf 'Waypaper: could not send failure notification\n' >&2
  failures=$((failures + 1))
}

restart_hyprpolkitagent() {
  local status

  if pkill -x hyprpolkitagent; then
    :
  else
    status=$?
    if ((status != 1)); then
      return "$status"
    fi
  fi

  hyprctl dispatch exec "$HOME/.config/hypr/scripts/hyprpolkitagent-launch"
}

if (($# != 1)); then
  run_step 'Wallpaper argument' false
  exit 1
fi

wallpaper=$1
run_step 'Matugen palette' matugen image "$wallpaper" -m dark --source-color-index=0 -t scheme-fidelity
run_step 'BreezeDark color scheme' plasma-apply-colorscheme BreezeDark
run_step 'Matugen color scheme' plasma-apply-colorscheme Matugen
run_step 'Hyprland reload' hyprctl reload
run_step 'Waybar reload' pkill -SIGUSR2 -x waybar
run_step 'SwayNC CSS reload' swaync-client --reload-css --skip-wait
run_step 'GTK file chooser restart' systemctl --user restart xdg-desktop-portal-gtk.service
run_step 'Hyprpolkitagent restart' restart_hyprpolkitagent

if ((failures > 0)); then
  exit 1
fi
