#/usr/bin/env bash

# tmux-dir-panes.sh opens each sub-directory in the current directory in a
# separate pane, setting the title for the pane to the sub-directory name
# itself.
#
# Useful for executing the same command on each sub-directory simultaneously,
# especially when `synchronize-panes` is bound to a convenient key.
# For example:
#   bind a set-window-option synchronize-panes

set -e

directories=$(ls -F | grep -E '.*/$' | xargs realpath)
for d in $directories; do
    tmux send-keys cd Space $d Enter
    tmux select-pane -T $(basename $d)
    tmux split-window
    tmux select-layout tiled
    sleep 0.3
done

# Handle off-by-one by closing the last split, and setting the pane layout to
# tile once more
tmux send-keys exit Enter
sleep 0.3
tmux select-layout tiled
