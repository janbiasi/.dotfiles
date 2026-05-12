if type brew &>/dev/null; then
  # source from brew
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

autoload -Uz compinit
compinit

if type zb &>/dev/null; then
  eval "$(zb completion zsh)"
fi

if type treepolicy &>/dev/null; then
  eval "$(treepolicy completion zsh)"
fi
