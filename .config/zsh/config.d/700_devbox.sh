if [ -x "$(command -v devbox)" ]; then
  eval "$(devbox global shellenv --init-hook)"
fi
