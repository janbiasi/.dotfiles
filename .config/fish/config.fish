# load shared aliases
source ~/.aliases

# Set config directories to ~/.config
set -x XDG_CONFIG_HOME "$HOME/.config"

# Use vim as preferred editor (locally aliased to nvim)
set -x EDITOR "vim"

# Add go binaries to path
set -x GOPATH (go env GOPATH)
set -x PATH $PATH (go env GOPATH)/bin
set -x GEM_HOME $PATH "$HOME/.gem"

# load homebrew completions
if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

# load homebrew installed package completions
if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

# initialize starship prompt
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
starship init fish | source

# initialize zoxide
zoxide init fish | source