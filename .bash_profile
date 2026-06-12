# XDG base directories (only set defaults if not already defined)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"

# Source .bashrc for interactive shell configuration
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# https://consoledonottrack.com/
export DO_NOT_TRACK=1

# Use 1Password SSH agent (Linux path)
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

  --color=hl:#77bdfb,hl+:#a2d2fb,info:#afaf87,marker:#7ce38b
  --color=prompt:#cea5fb,spinner:#c6cdd5,pointer:#faa356,header:#87afaf
  --color=border:#89929b,separator:#89929b,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"
  --info="right"'

# python uv settings
export UV_PYTHON_PREFERENCE=only-managed

# gemini cli doesn't follow xdg - https://github.com/google-gemini/gemini-cli/issues/1825
export GEMINI_CLI_SYSTEM_DEFAULTS_PATH="$XDG_CONFIG_HOME/gemini/system"
export GEMINI_CLI_SYSTEM_SETTINGS_PATH="$XDG_CONFIG_HOME/gemini/system"
# codex doesn't follow xdg - https://github.com/openai/codex/issues/1980
export CODEX_HOME="$XDG_CONFIG_HOME/codex"
# sqlit doesn't follow xdg
export SQLIT_CONFIG_DIR="$XDG_CONFIG_HOME/sqlit"
# pi doesn't follow xdg - https://github.com/earendil-works/pi/issues/2870
export PI_CODING_AGENT_DIR="$XDG_CONFIG_HOME/pi"
# paseo doesn't follow xdg - https://github.com/earendil-works/paseo/issues/
export PASEO_HOME="$XDG_CONFIG_HOME/paseo"

# PATH additions
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.bun/bin"
export PATH="$PATH:$HOME/.opencode/bin"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.atuin/bin"
export PATH="$PATH:$HOME/.docker/bin"
export PATH="$PATH:$HOME/.local/share/pnpm"
