#!/bin/sh

color=$(awk '$1 == "@define-color" && $2 == "success" { sub(/;$/, "", $3); print $3; exit }' "$HOME/.config/waybar/tokens/colors.css")
for vendor in anthropic openai; do
  case "$vendor" in
    anthropic) icon='' ;;
    openai) icon='' ;;
  esac

"$HOME/.local/bin/ai-usagebar" --vendor "$vendor" --color-low "$color" --json | jq -c --arg icon "$icon" '
  .text |= (
    if test("[0-9]+(?:\\.[0-9]+)?%") then
      (match("^<span[^>]*>")?.string // "") as $span
      | capture("(?<percentage>[0-9]+(?:\\.[0-9]+)?%)").percentage as $percentage
      | $span + $icon + " " + $percentage + (if $span == "" then "" else "</span>" end)
    else
      $icon + " " + .
    end
  )
'
done | jq -sc '{
  text: (map(.text) | join("  ")),
  tooltip: (map(.tooltip) | join("\n\n")),
  class: (map(.class) | unique)
}'
