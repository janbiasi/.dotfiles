# direnv hook - see https://direnv.net/docs/hook.html
if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook bash)"
fi
