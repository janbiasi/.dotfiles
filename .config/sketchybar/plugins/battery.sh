#!/bin/sh

source "$CONFIG_DIR/themes/catppuccin.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  9[0-9]|100)
    ICON="􀛨"
    ICON_COLOR=$GREEN
    ;;
  [6-8][0-9])
    ICON="􀺸"
    ICON_COLOR=$GREEN
    ;;
  [3-5][0-9])
    ICON="􀺶"
    ICON_COLOR=$ORANGE
    ;;
  [1-2][0-9])
    ICON="􀛩"
    ICON_COLOR=$RED
    ;;
  *)
    ICON="􀛪"
    ICON_COLOR=$RED
esac

if [[ $CHARGING != "" ]]; then
  ICON="􀢋"
  ICON_COLOR=$GREEN
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set $NAME \
           icon="$ICON" \
           label="${PERCENTAGE}%" \
           icon.color=${ICON_COLOR}
