# Use zoxide – A smarter cd command. Supports all major shells.
# https://github.com/ajeetdsouza/zoxide
if [ -x "$(command -v zoxide)" ]; then
  eval "$(zoxide init bash)"
fi

# https://github.com/alexpasmantier/television
if [ -x "$(command -v tv)" ]; then
  eval "$(tv init bash)"
fi
