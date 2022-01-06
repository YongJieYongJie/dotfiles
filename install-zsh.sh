#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
    sudo apt-get install -y zsh
elif [ "$os" = "Darwin" ]; then
    brew install zsh
fi

if [ -f "${HOME}/.zshrc" ] || [ -L "${HOME}/.zshrc"]; then
    backupFile=.zshrc.bak.`date +%Y%m%d_%H%M`
    mv "${HOME}/.zshrc" "${HOME}/$backupFile"
fi
ln -s "${DOTFILES_INSTALLERS_DIR}/home/.zshrc" "${HOME}/.zshrc"

# Install package manager for zsh: Zinit. Instructions from
# https://github.com/zdharma-continuum/zinit#automatic-installation-recommended.
echo "n" | sh -c "$(curl -fsSL https://git.io/zinit-install)"
