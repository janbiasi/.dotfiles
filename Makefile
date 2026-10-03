DOTFILES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SYSTEM := $(shell uname -s)
STOW_OPTIONS := --verbose --no-folding --target="$(HOME)" --dir="$(DOTFILES)"

ifeq ($(SYSTEM),Linux)
STOW_IGNORE_OPTIONS := --ignore='^Library(/|$$)'
endif

NVIM_CONFIG_DIR=${HOME}/.config/nvim
NVIM_CONFIG_REPO=git@github.com:janbiasi/nvim.config.git
DOTFILES_REPO_SSH_URL=git@github.com:janbiasi/.dotfiles.git
# TMUX_SHARE=${HOME}/.local/share/tmux

.PHONY: install-runtime-config
install-runtime-config:
ifeq ($(SYSTEM),Linux)
	@mkdir -p "$(HOME)/.config/waybar/tokens"
	@test -e "$(HOME)/.config/waybar/tokens/colors.css" || cp "$(DOTFILES)/.config/waybar/fallback-colors.css" "$(HOME)/.config/waybar/tokens/colors.css"
endif

.PHONY: update
update: update-dotfiles update-nvim

.PHONY: update-nvim
update-nvim:
	cd ${NVIM_CONFIG_DIR} && git pull -f

.PHONY: update-dotfiles
update-dotfiles: install-runtime-config
	stow $(STOW_OPTIONS) $(STOW_IGNORE_OPTIONS) --restow .
	$(MAKE) install-pi-extensions

.PHONY: theme
theme:
	@test -n "$(WALLPAPER)" || { echo 'Usage: make theme WALLPAPER=/path/to/image' >&2; exit 1; }
	@test -f "$(WALLPAPER)" || { echo 'Wallpaper file does not exist: $(WALLPAPER)' >&2; exit 1; }
	@command -v matugen >/dev/null || { echo 'matugen is not installed' >&2; exit 1; }
	matugen image "$(WALLPAPER)" --config "$(DOTFILES)/.config/matugen/config.toml" -m dark --source-color-index=0 -t scheme-fidelity
	plasma-apply-colorscheme Matugen

.PHONY: install-nvim
install-nvim:
	git clone ${NVIM_CONFIG_REPO} ${NVIM_CONFIG_DIR}

.PHONY: brew
install-brew:
	brew bundle --file="$(DOTFILES)/extra/homebrew/Brewfile"

.PHONY: dump-brew
dump-brew:
	brew bundle dump --force --file="./extra/homebrew/Brewfile"

.PHONE: configure-credentials
configure-credentials:
	@echo Loading environment secrets from 1Password ...
	op inject -i $(DOTFILES)/.envrc.tpl -o $(HOME)/.envrc
	@echo Created direnv $(HOME)/.envrc successfully
	source ~/.zprofile

.PHONY: configure-macos
configure-macos:
	# Run macOS configuration bash script
	$(DOTFILES)/extra/.macos

.PHONY: configure-macos-fish-default
configure-macos-fish-default:
	echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
	chsh -s /opt/homebrew/bin/fish

.PHONY: install-arch
install-arch:
	# Install Arch packages from packages.txt
	sudo pacman -S --needed - < "$(DOTFILES)/extra/arch/packages.txt"

.PHONY: install-aur
install-aur:
	# Install AUR packages from aur.txt (requires yay)
	yay -S --needed - < "$(DOTFILES)/extra/arch/aur.txt"

.PHONY: install-flatpak
install-flatpak:
	# Install flatpak apps from flatpak.txt (requires flatpak + flathub)
	flatpak install --system --noninteractive --or-update $$(grep -vE '^\s*(#|$$)' "$(DOTFILES)/extra/arch/flatpak.txt")

.PHONY: install-etc
install-etc:
	@test "$(SYSTEM)" = Linux || { echo "install-etc requires Linux." >&2; exit 1; }
	cd "$(DOTFILES)/etc" && find . -type f -exec sh -c 'for file do sudo install -D -o root -g root -m 644 -- "$$file" "/etc/$$file" || exit; done' sh {} +

.PHONY: configure-linux
configure-linux: configure-oomd

.PHONY: configure-oomd
configure-oomd: install-etc
	sudo systemctl daemon-reload
	sudo systemctl enable --now systemd-oomd.service
	sudo systemctl restart systemd-oomd.service
	systemctl --user daemon-reload
	oomctl

.PHONY: configure-polkit-fingerprint
configure-polkit-fingerprint:
	sudo install -Dm644 "$(DOTFILES)/extra/arch/polkit-1" /etc/pam.d/polkit-1
