# go
set -x GOPATH (go env GOPATH)
set -x PATH $PATH (go env GOPATH)/bin

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

# Load shared aliases
source ~/.aliases

