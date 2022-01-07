#!/usr/bin/env sh

scriptDir=`dirname "$0"`
DOTFILES_INSTALLERS_DIR=`cd $scriptDir;pwd`
homeDir=${HOME:-~}

echo "[*] Executing installation script located at ${DOTFILES_INSTALLERS_DIR}..."

# ------------------------------------------------- Set up configurations ------

for dotfile in .profile .bashrc
do
    echo "[*] Creating a symlink at $homeDir/$dotfile pointing to ${DOTFILES_INSTALLERS_DIR}/home/$dotfile..."
    if test -f "$homeDir/$dotfile" || test -L "$homeDir/$dotfile"; then
        backupFile=$dotfile.bak.`date +%Y%m%d_%H%M`
        echo "[!] $dotfile already exist at $homeDir, backing up to $backupFile"
        mv "$homeDir/$dotfile" "$homeDir/$backupFile"
    fi
    ln -s "${DOTFILES_INSTALLERS_DIR}/home/$dotfile" "$homeDir/$dotfile"
done

