# load atuin history
# https://docs.atuin.sh/
if [ -x "$(command -v atuin)" ]; then
   eval "$(atuin init bash)"
fi
