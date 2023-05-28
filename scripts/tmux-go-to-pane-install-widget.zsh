# Create a widget to run the tmux-go-to-pane.sh script without affecting
# command history, and bind it to meta-g.
#
# Note: this file should be sourced, and not executed.

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

tmux-go-to-pane-widget() {
    "$SCRIPTPATH/tmux-go-to-pane.sh"
}
zle -N tmux-go-to-pane-widget
bindkey '\eg' tmux-go-to-pane-widget
