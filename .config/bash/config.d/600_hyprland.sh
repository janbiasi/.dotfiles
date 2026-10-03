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
