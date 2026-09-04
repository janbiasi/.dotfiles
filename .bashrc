# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load aliases
if [ -f "$XDG_CONFIG_HOME/bash/.aliases" ]; then
  source "$XDG_CONFIG_HOME/bash/.aliases"
fi

# Load all config files in order
mapfile -t configs < <(printf '%s\n' "$XDG_CONFIG_HOME/bash/config.d/"*.sh | sort -V)
for conf in "${configs[@]}"; do
  if [ -n "${DEBUG_BASH_AUTOLOAD+1}" ]; then
    echo "Loading configuration ${conf} ..."
  fi
  source "$conf"
done
unset conf configs
