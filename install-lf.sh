#!/usr/bin/env sh

command -v lf > /dev/null && exit

if [ "$os" = "Linux" ]; then
    # Based on instructions at https://github.com/gokcehan/lf#installation.
    env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest
elif [ "$os" = "Darwin" ]; then
    brew install lf
fi

SettingsFilePath=${HOME}/.config/lf/lfrc
SettingsLinkTarget=${DOTFILES_INSTALLERS_DIR}/lfrc
echo "[*] Creating a symlink at $SettingsFilePath pointing to $SettingsLinkTarget"
if test -f "$SettingsFilePath" || test -L "$SettingsLinkTarget"; then
    backupFile=$SettingsFilePath.bak.`date +%Y%^b%d_%H%M`
    echo "[!] $SettingsFilePath already exist, backing up to $backupFile"
    mv "$SettingsFilePath" "$backupFile"
fi
ln -s "$SettingsLinkTarget" "$SettingsFilePath"
