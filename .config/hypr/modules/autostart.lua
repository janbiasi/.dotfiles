-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
  hl.exec_cmd("hypridle")
  -- waybar runs as a systemd user service (see systemd/user/waybar.service),
  -- not from autostart, so it gets API keys via EnvironmentFile.
  hl.exec_cmd("systemctl --user start swaync.service")
  hl.exec_cmd("swayosd-server")
  hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
  hl.exec_cmd("hyprsunset")
  hl.exec_cmd("~/.config/waybar/scripts/screen-share-indicator.py")
  hl.exec_cmd("waypaper --restore --no-post-command")
  hl.exec_cmd("voxtype --no-hotkey daemon")
  hl.exec_cmd("1password --silent")
  hl.exec_cmd("easyeffects --gapplication-service")
end)
