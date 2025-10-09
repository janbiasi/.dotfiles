
# Set config and data share directories like they should be
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_DIRS="$XDG_CONFIG_HOME:$HOME/Library/Preferences:$HOME/Library/Application Support:$HOME/Library/Preferences"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="$XDG_DATA_HOME:$HOME/Library/Application Support"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"
export TERM=xterm-256color

# Load additional credentials if available
if [ -f ~/.credentials ]; then 
  source ~/.credentials
fi

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

export PATH="$PATH:/opt/homebrew/bin"
export PATH="$PATH:/.atuin/bin"
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
export PATH="$PATH:$HOME/.docker/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$(brew --prefix)/opt/ruby/bin" # override for macOS
export PATH="$PATH:$HOME/.gem/bin"
export PATH="$PATH:$HOME/Library/pnpm"
export PATH="$PATH:$(brew --prefix)/opt/libpq/bin"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

# GitHub Dark theme for FZF (used by sesh amm.)
# https://vitormv.github.io/fzf-themes#eyJib3JkZXJTdHlsZSI6InJvdW5kZWQiLCJib3JkZXJMYWJlbCI6IiIsImJvcmRlckxhYmVsUG9zaXRpb24iOjAsInByZXZpZXdCb3JkZXJTdHlsZSI6InJvdW5kZWQiLCJwYWRkaW5nIjoiMCIsIm1hcmdpbiI6IjAiLCJwcm9tcHQiOiI+ICIsIm1hcmtlciI6Ij4iLCJwb2ludGVyIjoi4peGIiwic2VwYXJhdG9yIjoi4pSAIiwic2Nyb2xsYmFyIjoi4pSCIiwibGF5b3V0IjoiZGVmYXVsdCIsImluZm8iOiJyaWdodCIsImNvbG9ycyI6ImZnKzojYzZjZGQ1LGJnKzojMTYxYjIyLGhsOiM3N2JkZmIsaGwrOiNhMmQyZmIsaW5mbzojYWZhZjg3LG1hcmtlcjojN2NlMzhiLHByb21wdDojY2VhNWZiLHNwaW5uZXI6I2M2Y2RkNSxwb2ludGVyOiNmYWEzNTYsaGVhZGVyOiM4N2FmYWYsYm9yZGVyOiM4OTkyOWIsc2VwYXJhdG9yOiM4OTkyOWIsbGFiZWw6I2FlYWVhZSxxdWVyeTojZDlkOWQ5In0=
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#c6cdd5,bg:-1,bg+:#161b22
  --color=hl:#77bdfb,hl+:#a2d2fb,info:#afaf87,marker:#7ce38b
  --color=prompt:#cea5fb,spinner:#c6cdd5,pointer:#faa356,header:#87afaf
  --color=border:#89929b,separator:#89929b,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"
  --info="right"'

# Cocoapods settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# python uv settings
export UV_PYTHON_PREFERENCE=only-managed
