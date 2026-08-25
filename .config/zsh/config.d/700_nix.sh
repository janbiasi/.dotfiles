if [ -x "$(command -v devbox)" ]; then
  eval "$(devbox global shellenv --init-hook)"
fi

if [ -x "$(command -v devenv)" ]; then
  eval "$(devenv hook zsh)"
fi
