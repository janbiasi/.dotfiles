if [ -x "$(command -v podman)" ]; then
  alias docker=podman
  export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
  export TESTCONTAINERS_RYUK_DISABLED=true
fi
