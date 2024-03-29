# Load brew shell environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# Required by Jetbrains Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# Docker Desktop
export PATH="$PATH:$HOME/.docker/bin"

# Go
export PATH="$PATH:$HOME/go/bin"

# Required by Cocoapods
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
. "$HOME/.cargo/env"
