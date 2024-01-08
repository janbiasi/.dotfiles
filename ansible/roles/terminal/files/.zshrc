# Use custom ZSH location synced by dotfiles
ZSH_CUSTOM=$HOME/.config/oh-my-zsh/custom

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to the oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Use zoxide – A smarter cd command. Supports all major shells.
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

# Corrects errors in previous console commands.
# https://github.com/nvbn/thefuck
eval "$(thefuck --alias fuck)"

# Initialize ZSH syntax highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting?tab=readme-ov-file
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Initialize powerlevel10k theme
# https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#oh-my-zsh
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# Updating behaviour
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 13   # update every 13 days

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# We use exa for ll'ish commands so we don't need any colors
DISABLE_LS_COLORS="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Autoload selected plugins
# Standard plugins can be found in $ZSH/plugins/
plugins=(git)

# Initialize oh-my-zsh
source $ZSH/oh-my-zsh.sh

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/oh-my-zsh/.p10k.zsh ]] || source ~/.config/oh-my-zsh/.p10k.zsh

# Load NVM (node version manager)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Load SDKMan (version manager for java amm.)
export SDKMAN_DIR="${HOME}/.sdkman"
[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ] && source "${HOME}/.sdkman/bin/sdkman-init.sh"
