if [ -x "$(command -v devbox)" ]; then
  source <(devbox completion zsh); compdef _devbox devbox
  eval "$(devbox global shellenv --init-hook)"
fi
