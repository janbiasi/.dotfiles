As codex clutters the configuration with whitelisted project directories, the config must be crafted manually:

```toml
[shell_environment_policy]
include_only = ["PATH", "HOME", "SHELL", "LC_ALL", "EDITOR", "DIRENV_DIR", "DIRENV_FILE"]

[permissions.dev.filesystem]
":root" = "read"
":workspace_roots" = "write"
"/tmp" = "write"
"~/.ssh" = "none"
"~/.gnupg" = "none"
"~/.password-store" = "none"
"~/.config/gh" = "none"
"~/.git-credentials" = "none"
"~/.kube" = "none"
"~/.aws" = "none"

[analytics]
enabled = false
```
