# Set config directories to ~/.config
XDG_CONFIG_HOME="$HOME/.config"

# smoother transitioning between vim modes
# 10ms for key sequences
KEYTIMEOUT=1

# Use zoxide – A smarter cd command. Supports all major shells.
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

# Corrects errors in previous console commands.
# https://github.com/nvbn/thefuck
eval "$(thefuck --alias fuck)"

# Initialize ZSH syntax highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting?tab=readme-ov-file
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch arm64"

# Load shared aliases for shells
[[ -f ~/.aliases ]] && source ~/.aliases

# Load NVM (node version manager)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Load SDKMan (version manager for java amm.)
export SDKMAN_DIR="${HOME}/.sdkman"
[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

# Use ruby installed via brew instead of system version
export PATH="$(brew --prefix)/opt/ruby/bin:$PATH"
# Use non-elevated rights for ruby gems (eg. gem install cocoapods --user-install)
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"

# Theming of NNN - https://github.com/jarun/nnn
# This second option relies on you're terminal using the catppuccin theme and well use true catppuccin colors:
BLK="03" CHR="03" DIR="04" EXE="02" REG="07" HARDLINK="05" SYMLINK="05" MISSING="08" ORPHAN="01" FIFO="06" SOCK="03" UNKNOWN="01"
export NNN_COLORS="#04020301;4231"
export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$UNKNOWN"

# Initialize starship - https://starship.rs/
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
eval "$(starship init zsh)"

