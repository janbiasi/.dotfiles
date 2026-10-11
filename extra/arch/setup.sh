#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "==> Installing Arch packages from packages.txt ..."
make -C "${DOTFILES_DIR}" install-arch

echo "==> Checking for yay (AUR helper) ..."
if ! command -v yay &>/dev/null; then
  echo "yay not found. Please install yay first: https://github.com/Jguer/yay"
  exit 1
fi

echo "==> Installing AUR packages from aur.txt ..."
make -C "${DOTFILES_DIR}" install-aur

echo "==> Installing flatpak apps from flatpak.txt ..."
make -C "${DOTFILES_DIR}" install-flatpak

echo "==> Setup complete."
echo "Next steps:"
echo "  1. Run 'make update-dotfiles' from ${DOTFILES_DIR}"
echo "  2. Run 'make configure-linux' to install system configuration and enable systemd-oomd"
echo "  3. Copy and adapt .gitconfig manually (it's not stowed)"
echo "  4. Run 'make install-nvim' to clone nvim config"
