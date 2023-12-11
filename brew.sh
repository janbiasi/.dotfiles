#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Standard Applications
brew install --cask 1password
brew install --cask rectangle
brew install --cask arc
brew install --cask raycast
brew install --cask spotify
brew install --cask raindropio
brew install --cask obsidian
brew install --cask hiddenbar
brew install --cask flameshot

# Editors and IDEs
brew install --cask visual-studio-code
brew install --cask zed
brew install --cask jetbrains-toolbox

# Developer tools
brew install --cask bruno
brew install git
brew install docker
brew install pnpm

# Command line stuff
brew install starship
brew install zoxide
brew install neovim

# Design and concept applications
brew install --cask figma
brew install --cask miro

# Nerd Fonts for Terminals
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font

# IINA video player as replacement for built-ins
brew tap iina/homebrew-mpv-iina
brew install mpv-iina

# Enable auto-updates as I usually don't interact with brew that often
# https://github.com/Homebrew/homebrew-autoupdate
brew tap homebrew/autoupdate

# Remove outdated versions from the cellar.
brew cleanup
