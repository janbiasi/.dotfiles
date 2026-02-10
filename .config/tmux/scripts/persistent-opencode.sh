#!/bin/bash
session_name="opencode-$(basename "$PWD" | tr '.' '-')"
current_dir="$PWD"

echo $session_name

# Create session if it doesn't exist
if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new -dAs "$session_name" -c "$current_dir" "opencode ."
fi

# Attach to session in popup
tmux display-popup -d "$current_dir" -w 90% -h 90% -E "tmux attach-session -t '$session_name'"
