#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
    command -v zsh > /dev/null || sudo apt-get install -y zsh
elif [ "$os" = "Darwin" ]; then
    command -v zsh > /dev/null || brew install zsh
fi

. "${DOTFILES_INSTALLERS_DIR}/lib/sh/helpers.sh"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/home/.zshrc"   "${HOME}/.zshrc"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/home/.bashrc"  "${HOME}/.bashrc"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/home/.profile" "${HOME}/.profile"

# Install package manager for zsh: Zinit. Instructions from
# https://github.com/zdharma-continuum/zinit#automatic-installation-recommended.
echo "n" | sh -c "$(curl -fsSL https://git.io/zinit-install)"
