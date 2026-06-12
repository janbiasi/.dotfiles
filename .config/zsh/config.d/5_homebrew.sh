# Load brew shell environment (macOS only)
if [[ "$OSTYPE" == darwin* ]] && [ -d /opt/homebrew ]; then
  export HOMEBREW_BUNDLE_FILE="$HOME/.dotfiles/extra/homebrew/Brewfile"
  export HOMEBREW_REQUIRE_TAP_TRUST=1
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
