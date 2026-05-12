export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# Initialize starship - https://starship.rs/
# NOTE: this needs to come before atuin in bash - see https://github.com/atuinsh/atuin/issues/2738
if [ -x "$(command -v starship)" ]; then
  eval "$(starship init bash --print-full-init)"
fi
