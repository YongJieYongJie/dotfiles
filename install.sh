#!/usr/bin/env sh

curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/.git-prompt.sh
curl -L git.io/antigen > ~/.antigen.zsh

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


scriptDir=`dirname "$0"`
absScriptDir=`cd $scriptDir;pwd`
homeDir=~

echo "[*] Executing installation script located at `dirname "$0"`..."

for dotfile in .bash_profile .bashrc .gitconfig .inputrc .profile .tmux.conf \
	.vimrc .zshrc
do
	echo "[*] Creating a symlink at $homeDir/$dotfile pointing to $absScriptDir/$dotfile..."
	if test -f "$homeDir/$dotfile" || test -L "$homeDir/$dotfile"; then
		backupFile=$dotfile.bak.`date +%Y%^b%d_%H%M`
		echo "[!] $dotfile already exist at $homeDir, backing up to $backupFile"
		mv "$homeDir/$dotfile" "$homeDir/$backupFile"
	fi
	ln -s "$absScriptDir/$dotfile" "$homeDir/$dotfile"
done


vim -c 'PluginInstall' -c 'qa!'

# Install package manager for zsh: Zinit.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)
