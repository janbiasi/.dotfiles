#!/usr/bin/env bash

# Load SDKMan (version manager for java amm.)
if [ -d "${HOME}/.sdkman" ]; then
  export SDKMAN_DIR="${HOME}/.sdkman"
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi
