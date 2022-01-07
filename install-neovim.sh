#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
  command -v vim  > /dev/null || sudo apt-get install -y vim
  command -v nvim > /dev/null || sudo apt-get install -y neovim
elif [ "$os" = "Darwin" ]; then
  command -v vim  > /dev/null || brew install vim
  command -v nvim > /dev/null || brew install neovim
fi

. "${DOTFILES_INSTALLERS_DIR}/lib/sh/helpers.sh"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/init.vim"          "${HOME}/.config/nvim/init.vim"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/coc-settings.json" "${HOME}/.config/nvim/coc-settings.json"

# Install plugin manager for Neovim.
curl -fLo ${HOME}/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins for Neovim, requires nodejs and yarn.
(cd ${HOME} && nvim --headless -c 'PlugInstall' -c 'qa!')
