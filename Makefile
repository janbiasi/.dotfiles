DOTFILES=${HOME}/.dotfiles
NVIM_CONFIG_DIR=${HOME}/.config/nvim
NVIM_CONFIG_REPO=git@github.com:janbiasi/nvim.config.git
# TMUX_SHARE=${HOME}/.local/share/tmux

install:
	stow -v --restow --target="$(HOME)" --dir="$(DOTFILES)" .

update: update-dotfiles update-nvim

update-nvim:
	cd ${NVIM_CONFIG_DIR} && git pull -f

update-dotfiles:
	stow -v --restow --adopt .

nvim:
	git clone ${NVIM_CONFIG_REPO} ${NVIM_CONFIG_DIR}

brew:
	brew bundle --file="$(DOTFILES)/extra/homebrew/Brewfile"

macos:
	$(DOTFILES)/.macos # bash script
