if status is-interactive
    # Commands to run in interactive sessions can go here
end

# go
set -x GOPATH (go env GOPATH)
set -x PATH $PATH (go env GOPATH)/bin