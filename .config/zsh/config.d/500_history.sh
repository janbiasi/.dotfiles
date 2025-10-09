
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

if [ -x "$(command -v setopt)" ]; then
  setopt appendhistory
  setopt sharehistory
  setopt hist_ignore_space
  setopt hist_ignore_all_dups
  setopt hist_save_no_dups
  setopt hist_ignore_dups
  setopt hist_find_no_dups
fi

# load atuin history
if [ -x "$(command -v atuin)" ]; then
  . "$HOME/.atuin/bin/env"
   eval "$(atuin init zsh)"
fi
