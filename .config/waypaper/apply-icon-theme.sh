#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  dark) icon_theme=breeze-dark ;;
  light) icon_theme=breeze ;;
  *) printf 'Usage: %s dark|light\n' "$0" >&2; exit 1 ;;
esac

kwriteconfig6 --file kdeglobals --group Icons --key Theme "$icon_theme" --notify
kwriteconfig6 --file "$HOME/.config/gtk-3.0/settings.ini" --group Settings --key gtk-icon-theme-name "$icon_theme"
kwriteconfig6 --file "$HOME/.config/gtk-4.0/settings.ini" --group Settings --key gtk-icon-theme-name "$icon_theme"
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
