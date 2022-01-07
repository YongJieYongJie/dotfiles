#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
    command -v tmux > /dev/null || sudo apt-get install -y tmux
elif [ "$os" = "Darwin" ]; then
    command -v tmux > /dev/null || brew install tmux
fi

. "${DOTFILES_INSTALLERS_DIR}/lib/sh/helpers.sh"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/home/.tmux.conf" "${HOME}/.tmux.conf"
