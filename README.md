<p align="center">
    <img width="500" src="./docs/screenshot-2026.png" />
</p>
<p align="center">
    <a href="#requirements">Requirements</a> · <a href="#included-configurations">Included Configurations</a> · <a href="#installation">Installation</a> · <a href="#available-tasks">Tasks</a>
</p>

## Dotfiles

This directory contains the dotfiles for my development environment.

**Shell split:** zsh on macOS, bash on Arch Linux.

### Requirements

- [Git](https://git-scm.com/)
- [Stow](https://www.gnu.org/software/stow/)
- [Make](https://www.gnu.org/software/make/)

### Included Configurations

- [1password](https://1password.com)
- [aerospace](https://nikitabobko.github.io/AeroSpace/guide) :apple:
- [atuin](https://atuin.sh/)
- [bash](https://www.gnu.org/software/bash/)
- [bat](https://github.com/sharkdp/bat)
- [btop](https://github.com/aristocratos/btop)
- [claude](https://www.claude.com/product/claude-code) 🧠
- [codex](https://openai.com/index/introducing-codex/) 🧠
- [devbox](https://www.jetify.com/devbox)
- [television](https://github.com/alexpasmantier/television)
- [ghostty](https://ghostty.org/)
- [jankyborders](https://github.com/FelixKratz/JankyBorders) :apple:
- [karabiner elements](https://karabiner-elements.pqrs.org/) :apple:
- [lazygit](https://github.com/jesseduffield/lazygit)
- [nix](https://nixos.org)
- [opencode](https://opencode.ai/) 🧠
- [pi](https://pi.dev) 🧠
- [posting](https://posting.sh/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [sketchybar](https://github.com/FelixKratz/SketchyBar) :apple: _(currently unused)_
- [starship](https://starship.rs)
- [tmux](https://github.com/tmux/tmux)
- [vhs](https://github.com/charmbracelet/vhs)
- [yazi](https://github.com/sxyazi/yazi)
- [zed](https://zed.dev)
- [zsh](https://www.zsh.org/) :apple:

## Installation

### macOS

#### 1. Install required software

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow make
```

#### 2. Clone Repository

```sh
git clone https://github.com/janbiasi/.dotfiles.git
cd .dotfiles
```

#### 3. Apply macOS configuration

```sh
make configure-macos
```

#### 4. Install dependencies

##### macOS

```sh
make install-brew
```

### Linux

```sh
# Install yay first if not already installed
# https://github.com/Jguer/yay

# Install pacman packages
make install-arch

# Install AUR packages
make install-aur
```

## Available tasks

| Task                    | Description                                                                                                |
| ----------------------- | ---------------------------------------------------------------------------------------------------------- |
| `install`               | Init configuration files to the local file system via [stow](https://www.gnu.org/software/stow/)           |
| `update`                | Convenience method; calls `update-dotfiles` and `update-nvim`                                              |
| `update-nvim`           | Pull latest changes from nvim.config repository                                                            |
| `update-dotfiles`       | Re-stows all configuration files                                                                           |
| `install-nvim`          | Installs the nvim configuration from the [nvim.config](https://github.com/janbiasi/nvim.config) repository |
| `install-brew`          | Installs all required software packages via [homebrew](https://brew.sh/)                                   |
| `configure-credentials` | Expands environment secrets from 1Password, see [.env.tpl](./.env.tpl)                                     |
| `configure-macos`       | Applies various macOS configurations, see [.macos](./extra/.macos)                                         |
| `install-arch`          | Installs required pacman packages on Arch Linux                                                            |
| `install-aur`           | Installs AUR packages on Arch Linux (requires yay)                                                         |
| `configure-linux`       | Applies Linux-specific configurations (placeholder)                                                        |
