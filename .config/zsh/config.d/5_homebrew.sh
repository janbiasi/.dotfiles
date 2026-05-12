# Load brew shell environment (macOS only)
if [[ "$OSTYPE" == darwin* ]] && [ -d /opt/homebrew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi