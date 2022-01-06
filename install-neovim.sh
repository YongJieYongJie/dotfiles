#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
  sudo apt-get install -y vim neovim
elif [ "$os" = "Darwin" ]; then
  command -v vim       > /dev/null || brew install vim
  command -v neovim    > /dev/null || brew install neovim
fi

# Symlinking Neovim's configuration and coc's settings
mkdir -p ${HOME}/.config/nvim
nvimConfigFilePath=${HOME}/.config/nvim/init.vim
nvimConfigLinkTarget=${DOTFILES_INSTALLERS_DIR}/init.vim
echo "[*] Creating a symlink at $nvimConfigFilePath pointing to $nvimConfigLinkTarget"
if test -f "$nvimConfigFilePath" || test -L "$nvimConfigLinkTarget"; then
    backupFile=$nvimConfigFilePath.bak.`date +%Y%m%d_%H%M`
    echo "[!] $nvimConfigFilePath already exist, backing up to $backupFile"
    mv "$nvimConfigFilePath" "$backupFile"
fi
ln -s "$nvimConfigLinkTarget" "$nvimConfigFilePath"

nvimCocSettingsFilePath=${HOME}/.config/nvim/coc-settings.json
nvimCocSettingsLinkTarget=${DOTFILES_INSTALLERS_DIR}/coc-settings.json
echo "[*] Creating a symlink at $nvimCocSettingsFilePath pointing to $nvimCocSettingsLinkTarget"
if test -f "$nvimCocSettingsFilePath" || test -L "$nvimCocSettingsLinkTarget"; then
    backupFile=$nvimCocSettingsFilePath.bak.`date +%Y%^b%d_%H%M`
    echo "[!] $nvimCocSettingsFilePath already exist, backing up to $backupFile"
    mv "$nvimCocSettingsFilePath" "$backupFile"
fi
ln -s "$nvimCocSettingsLinkTarget" "$nvimCocSettingsFilePath"

# Install plugin manager for Neovim.
curl -fLo ${HOME}/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Install plugins for Neovim, requires nodejs and yarn.
(cd ${HOME} && nvim --headless -c 'PlugInstall' -c 'qa!')
