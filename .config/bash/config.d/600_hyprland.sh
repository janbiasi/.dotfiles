waybar-hot-reload() {
  # Ensure inotify-tools is installed
  if ! command -v inotifywait &> /dev/null; then
      echo "Error: inotifywait not found. Install inotify-tools."
      exit 1
  fi

  echo "Monitoring Waybar config files for changes..."

  inotifywait -m -r -e create -e modify -e delete "$HOME/.config/waybar" |
  while read -r path _; do
      echo "Change detected in $path. Reloading Waybar..."
      killall -SIGUSR2 waybar
  done
}

sddm-test() {
    sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/pixie
}

polkit-agent-restart() {
  systemctl --user restart plasma-polkit-agent.service
}

# Hyprland: place the external display centered above the laptop screen.
# Moving a monitor leaves its workspace with a stale render offset (windows
# drawn off screen), so bounce DP-1 through another workspace afterwards.
hypr-screen-above() {
  local prev ws
  prev=$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')
  hyprctl eval 'hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-center-up", scale = 1.25 })' >/dev/null
  sleep 0.5
  ws=$(hyprctl monitors -j | jq -r '.[] | select(.name == "DP-1").activeWorkspace.id')
  hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-1" })' >/dev/null
  hyprctl dispatch 'hl.dsp.focus({ workspace = 9 })' >/dev/null
  hyprctl dispatch "hl.dsp.focus({ workspace = $ws })" >/dev/null
  hyprctl dispatch "hl.dsp.focus({ monitor = \"$prev\" })" >/dev/null
}
