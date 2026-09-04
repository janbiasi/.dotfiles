#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "==> Installing Arch packages from packages.txt ..."
if [ -f "${SCRIPT_DIR}/packages.txt" ]; then
  sudo pacman -S --needed - < "${SCRIPT_DIR}/packages.txt"
fi

echo "==> Checking for yay (AUR helper) ..."
if ! command -v yay &>/dev/null; then
  echo "yay not found. Please install yay first: https://github.com/Jguer/yay"
  exit 1
fi

echo "==> Installing AUR packages from aur.txt ..."
if [ -f "${SCRIPT_DIR}/aur.txt" ]; then
  yay -S --needed - < "${SCRIPT_DIR}/aur.txt"
fi

# echo "==> Enabling Docker service ..."
# sudo systemctl enable --now docker.service || true

echo "==> Setup complete."
echo "Next steps:"
echo "  1. Run 'make install-configs' from ${DOTFILES_DIR}"
echo "  2. Copy and adapt .gitconfig manually (it's not stowed)"
echo "  3. Run 'make install-nvim' to clone nvim config"
