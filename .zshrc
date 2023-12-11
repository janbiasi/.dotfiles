# Use starship - The minimal, blazing-fast, and infinitely customizable prompt
# https://starship.rs/
eval "$(starship init zsh)"

# Use zoxide – A smarter cd command. Supports all major shells.
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

# GPG Deamon used for commit signing
export GPG_TTY=$(tty)

# Better ls command
alias ls='exa --git --icons --color=always --group-directories-first'

# Alias "cd" to zoxide's "z"
alias cd='z'

# DNS cache flushing utility
alias flush-dns-cache="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Alias ll to a better variant
alias ll='ls -la'

# Useful parent cd aliases
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../../'

# Common programming aliases
alias gradle-dev="./gradlew bootRun --args='--spring.profiles.active=dev'"

# Setup NVM for node version management
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Setup SDKMAN for java version management
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
