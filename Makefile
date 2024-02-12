DOTFILES=${HOME}/dotfiles
# TMUX_SHARE=${HOME}/.local/share/tmux

install:
	stow -v --restow --target="$(HOME)" --dir="$(DOTFILES)" .

update:
	stow -v --adopt .

brew:
	brew bundle --file="$(DOTFILES)/extra/homebrew/Brewfile"

macos:
	$(DOTFILES)/.macos # bash script
