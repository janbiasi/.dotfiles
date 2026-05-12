if [ -x "$(command -v devbox)" ]; then
  source <(devbox completion bash)
  eval "$(devbox global shellenv --init-hook)"
fi
