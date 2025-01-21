<p align="center">
    <img width="500" src="./docs/screenshot.png" />
</p>
<p align="center">
    <a href="#requirements">Requirements</a> · <a href="#included-configurations">Included Configurations</a> · <a href="#installation">Installation</a> · <a href="#available-tasks">Tasks</a>
</p>

## Dotfiles

This directory contains the dotfles for my development environment

### Requirements

- [Git](https://git-scm.com/)
- [Stow](https://www.gnu.org/software/stow/)
- [Make](https://www.gnu.org/software/make/)

### Included Configurations

- [1password](https://1password.com) :apple: :penguin:
- [aerospace](https://nikitabobko.github.io/AeroSpace/guide) :apple:
- [atuin](https://atuin.sh/) :apple: :penguin:
- [btop](https://github.com/aristocratos/btop) :apple: :penguin:
- [ghostty](https://ghostty.org/) :apple: :penguin:
- [lazygit](https://github.com/jesseduffield/lazygit) :apple: :penguin:
- [neofetch](https://github.com/dylanaraps/neofetch) :apple: :penguin:
- [nix](https://nixos.org) :apple: :penguin:
- [ripgrep](https://github.com/BurntSushi/ripgrep) :apple: :penguin:
- [sketchybar](https://github.com/FelixKratz/SketchyBar) :apple:
- [starship](https://starship.rs) :apple: :penguin:
- [tmux](https://github.com/tmux/tmux) :apple: :penguin:
- [yazi](https://github.com/sxyazi/yazi) :apple: :penguin:
- [zed](https://zed.dev) :apple: :penguin:

### Installation

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

##### linux

_not available yet_

#### 5. Apply or update setup configuration

```sh
make install-configs # initially
make install-nvim # clones neovim config (requires install / SSH key via 1password)
make update # apply incremental updates
```

### Available tasks

| Task                           | Description                                                                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| `install-configs`              | Sync configuration files to the local file system via [stow](https://www.gnu.org/software/stow/)           |
| `update`                       | Convenience method; calls `update-dotfiles` and `update-nvim`                                              |
| `update-nvim`                  | Pull latest changes from nvim.config repository                                                            |
| `update-dotfiles`              | Re-stows all configuration files                                                                           |
| `install-nvim`                 | Installs the nvim configuration from the [nvim.config](https://github.com/janbiasi/nvim.config) repository |
| `install-brew`                 | Installs all required software packages via [homebrew](https://brew.sh/)                                   |
| `configure-macos`              | Applies various macOS configurations, see [.macos](./extra/.macos)                                         |
| `configure-macos-fish-default` | Sets the default shell to fish on macOS                                                                    |
