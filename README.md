# Dotfiles

This directory contains the dotfles for my system

## Requirements

- [Git](https://git-scm.com/)
- [Stow](https://www.gnu.org/software/stow/)

## Installation

### 1. Install required software

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
```

### 2. Clone Repository

```sh
git clone --recurse-submodules https://github.com/janbiasi/.dotfiles.git
```

### 3. Apply macOS configuration

```sh
./dotfiles/.macos # bash script
```

### 4. Apply setup configuration

```sh
cd .dotfiles
stow -v .
# incremental via:
# stow --adopt . -v

```

## Maintenance

### Updating

To link the latest nvim configuration you need to update the contained submodule

```sh
git pull --recurse-submodules
```
