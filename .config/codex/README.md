# Codex configuration

The local `config.toml` is ignored by Git because Codex adds machine-specific trusted projects to it.
Keep the reusable settings in this example:

```toml
[shell_environment_policy]
include_only = ["PATH", "HOME", "SHELL", "LC_ALL", "EDITOR", "DIRENV_DIR", "DIRENV_FILE"]

[permissions.dev.filesystem]
":root" = "read"
":workspace_roots" = "write"
"/tmp" = "write"
"/home/$USER/.cache/nix" = "write"
"/home/$USER/.cache/devenv" = "write"
"/home/$USER/.cargo" = "write"
"/home/$USER/.ssh" = "deny"
"/home/$USER/.gnupg" = "deny"
"/home/$USER/.password-store" = "deny"
"/home/$USER/.config/gh" = "deny"
"/home/$USER/.git-credentials" = "deny"
"/home/$USER/.kube" = "deny"
"/home/$USER/.aws" = "deny"

[permissions.dev.network]
enabled = true

[permissions.dev.network.unix_sockets]
"/nix/var/nix/daemon-socket/socket" = "allow"
"/home/$USER/.config/herdr/herdr.sock" = "allow"

[analytics]
enabled = false
```
