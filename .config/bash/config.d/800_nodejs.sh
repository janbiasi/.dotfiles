
# Load FNM (node version manager)
if [ -x "$(command -v fnm)" ]; then
  eval "$(fnm env --use-on-cd --shell bash)"
  eval "$(fnm completions --shell bash)"
fi
