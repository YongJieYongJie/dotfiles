#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
  sudo apt-get install -y emacs
elif [ "$os" = "Darwin" ]; then
  brew install emacs
fi

# Symlinking Emacs's configuration
mkdir -p ${HOME}/.emacs.d
emacsConfigFilePath=${HOME}/.emacs.d/init.el
emacsConfigLinkTarget=${DOTFILES_INSTALLERS_DIR}/init.el
echo "[*] Creating a symlink at $emacsConfigFilePath pointing to $emacsConfigLinkTarget"
if test -f "$emacsConfigFilePath" || test -L "$emacsConfigLinkTarget"; then
    backupFile=$emacsConfigFilePath.bak.`date +%Y%m%d_%H%M`
    echo "[!] $emacsConfigFilePath already exist, backing up to $backupFile"
    mv "$emacsConfigFilePath" "$backupFile"
fi
ln -s "$emacsConfigLinkTarget" "$emacsConfigFilePath"
