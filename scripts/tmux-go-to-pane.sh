#!/usr/bin/env bash

# tmux-go-to-pane.sh allows fast interactive switch to specific tmux panes (in
# the same session) using fzf.

set -e

target=$(tmux list-panes -a -F'$#{session_id} #I #W #D #T' | fzf)
window=$(echo $target | cut -d' ' -f2)
pane=$(echo $target | cut -d' ' -f4)
tmux select-window -t $window
tmux select-pane -t $pane

# Zoom in
tmux list-panes -F '#F' | grep -q Z || tmux resize-pane -Z
