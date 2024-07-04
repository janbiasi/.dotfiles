# History configuration
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Use zoxide – A smarter cd command. Supports all major shells.
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

# Corrects errors in previous console commands.
# https://github.com/nvbn/thefuck
eval "$(thefuck --alias fuck)"

# Tmux session templates
# https://github.com/jimeh/tmuxifier
eval "$(tmuxifier init -)"

# Fuzzyfinder
# https://github.com/junegunn/fzf
eval "$(fzf --zsh)"

# Initialize ZSH syntax highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting?tab=readme-ov-file
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Initialize ZSH autocompletions like fish
# https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Run compinit
autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# terraform autocompletions
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Load ZSH completions from homebrew installed packages
 if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

# Load shared aliases for shells
[[ -f ~/.aliases ]] && source ~/.aliases

# Load NVM (node version manager)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Load SDKMan (version manager for java amm.)
export SDKMAN_DIR="${HOME}/.sdkman"
[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

# Google Cloud SDK
if [ -f "$HOME/.google/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/.google/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/.google/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/.google/google-cloud-sdk/completion.zsh.inc"; fi

# Initialize starship - https://starship.rs/
eval "$(starship init zsh)"

# Yazi wrapper - https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

