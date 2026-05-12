# Enable bash programmable completion features
if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

if type treepolicy &>/dev/null; then
  source <(treepolicy completion bash)
fi

if type lazygit &>/dev/null; then
  source <(lazygit completion bash)
fi
