# Use zoxide – A smarter cd command. Supports all major shells.
# https://github.com/ajeetdsouza/zoxide
if [ -x "$(command -v zoxide)" ]; then
  eval "$(zoxide init zsh)"
fi

# Fuzzyfinder
# https://github.com/junegunn/fzf
if [ -x "$(command -v fzf)" ]; then
  source <(fzf --zsh)
fi