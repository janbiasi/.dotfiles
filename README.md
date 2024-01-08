# Dotfiles

Personal dotfiles new machines or migrations to have the same settings accross multiple machines, powered by [ansible](https://www.ansible.com/).

## Installation

### 1. Clone repository to ~/.dotfiles

```sh
git clone https://github.com/janbiasi/.dotfiles.git
```

### 2. Install ansible

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ansible
```

### 3. Run installer

```sh
./ansible/install
```
