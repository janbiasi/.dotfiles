DOTFILES=${HOME}/.dotfiles
NVIM_CONFIG_DIR=${HOME}/.config/nvim
NVIM_CONFIG_REPO=git@github.com:janbiasi/nvim.config.git
DOTFILES_REPO_SSH_URL=git@github.com:janbiasi/.dotfiles.git
# TMUX_SHARE=${HOME}/.local/share/tmux

.PHONY: install-configs
install-configs:
	# Sync configuration files
	stow -v --restow --target="$(HOME)" --dir="$(DOTFILES)" .
	# Change from HTTPS to SSH as we now have 1Password providing our SSH key
	git remote set-url origin $(DOTFILES_REPO_SSH_URL)

.PHONY: update
update: update-dotfiles update-nvim

.PHONY: update-nvim
update-nvim:
	cd ${NVIM_CONFIG_DIR} && git pull -f

.PHONY: update-dotfiles
update-dotfiles:
	stow -v --restow --adopt .

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
	op inject -i $(DOTFILES)/.credentials.tpl -o $(HOME)/.credentials
	@echo Created $(HOME)/.credentials successfully

.PHONY: configure-macos
configure-macos:
	# Run macOS configuration bash script
	$(DOTFILES)/.macos 

.PHONY: configure-macos-fish-default
configure-macos-fish-default:
	echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
	chsh -s /opt/homebrew/bin/fish