if [ -x "$(command -v devbox)" ]; then
  source <(devbox completion zsh); compdef _devbox devbox
fi