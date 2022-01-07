#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
  command -v emacs > /dev/null || sudo apt-get install -y emacs
elif [ "$os" = "Darwin" ]; then
  command -v emacs > /dev/null || brew install emacs
fi

. "${DOTFILES_INSTALLERS_DIR}/lib/sh/helpers.sh"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/init.el" "${HOME}/.emacs.d/init.el"
