new_window "editor"
new_window "terminal"

# Split window into panes.
split_v 20
split_h 30

# Run commands.
run_cmd "nvim"     # runs in active pane
run_cmd "npm start" 1  # runs in pane 1

# Paste text
#send_keys "top"    # paste into active pane
#send_keys "date" 1 # paste into pane 1

# Set active pane.
select_pane 0
