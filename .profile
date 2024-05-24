# Set config and data share directories like linux
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_SHARE="$HOME/.local/share"

# Set starship configuration
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# smoother transitioning between vim modes
# 10ms for key sequences
export KEYTIMEOUT=1

# Load brew shell environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# Required by Jetbrains Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# Docker Desktop
export PATH="$PATH:$HOME/.docker/bin"

# Go
export PATH="$PATH:$HOME/go/bin"

# tmuxifier
export PATH="$PATH:$XDG_CONFIG_HOME/tmux/plugins/tmuxifier/bin"
export TMUXIFIER_LAYOUT_PATH="$XDG_CONFIG_HOME/tmux/layouts"

# Add Cargo to path
export PATH="$HOME/.cargo/env:$PATH"
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
