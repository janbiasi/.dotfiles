# Set config and data share directories like they should be
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_DIRS="$XDG_CONFIG_HOME:$HOME/Library/Preferences:$HOME/Library/Application Support:$HOME/Library/Preferences"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="$XDG_DATA_HOME:$HOME/Library/Application Support"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"
# export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Set starship configuration
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# Load brew shell environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Use 1Password SSH agent
export SSH_AUTH_SOCK="$HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Main obsidian vault
export OBSIDIAN_VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain/"

# smoother transitioning between vim modes
# 10ms for key sequences
export KEYTIMEOUT=1

# Required by Jetbrains Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# Docker Desktop
export PATH="$PATH:$HOME/.docker/bin"

# Go
export PATH="$PATH:$HOME/go/bin"

# Other binaries
export PATH="$PATH:$HOME/bin"

# Add Cargo to path
export PATH="$PATH:$HOME/.cargo/env"
. "$HOME/.cargo/env"

# Use Ruby installed via brew instead of system version
export PATH="$(brew --prefix)/opt/ruby/bin:$PATH"
export PATH="$PATH:$HOME/.gem/bin"

# Catppuccin theme for FZF
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Cocoapods settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
