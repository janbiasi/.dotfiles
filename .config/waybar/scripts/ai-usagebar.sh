#!/bin/sh

color=$(awk '$1 == "@define-color" && $2 == "success" { sub(/;$/, "", $3); print $3; exit }' "$HOME/.config/waybar/tokens/colors.css")
exec "$HOME/.local/bin/ai-usagebar" --icon '󰚩' --color-low "$color"
