#!/usr/bin/env sh

command -v tmux > /dev/null && exit 0

if [ "$os" = "Linux" ]; then
    sudo apt-get install -y tmux
elif [ "$os" = "Darwin" ]; then
    brew install tmux
fi

settingsFilePath=${HOME}/.tmux.conf
settingsLinkTarget=${DOTFILES_INSTALLERS_DIR}/home/.tmux.conf
echo "[*] Creating a symlink at $settingsFilePath pointing to $settingsLinkTarget"
if [ -f "$settingsFilePath" ] || [ -L "$settingsLinkTarget" ]; then
    backupFile=$settingsFilePath.bak.`date +%Y%^b%d_%H%M`
    echo "[!] $settingsFilePath already exist, backing up to $backupFile"
    mv "$settingsFilePath" "$backupFile"
fi
ln -s "$settingsLinkTarget" "$settingsFilePath"
