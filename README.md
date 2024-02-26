# Dotfiles

This directory contains the dotfles for my development environment

## Requirements

- [Git](https://git-scm.com/)
- [Stow](https://www.gnu.org/software/stow/)
- [Make](https://www.gnu.org/software/make/)

## Installation

### 1. Install required software

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow make
```

### 2. Clone Repository

```sh
git clone git@github.com:janbiasi/.dotfiles.git
cd .dotfiles
```

### 3. Apply macOS configuration

```sh
make macos
```

### 4. Apply or update setup configuration

```sh
make install
# ... or incremental update via:
make update
```

### 5. Setup Git environment

> [!IMPORTANT]
> The git configuration is **not** automatically synced as it requires additional (sensitive) information. Please follow the next three steps.

- Copy the `.gitconfig` file from the repository manually
- Add the missing signing key under the `[gpg "ssh"]`
- Save the file to the home directory
