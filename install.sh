#!/bin/sh

curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/.git-prompt.sh
curl -L git.io/antigen > ~/.antigen.zsh

.bash_profile*
.bashrc*
.git/
.gitconfig*
.git-prompt.sh*
.inputrc*
.minttyrc
.profile*
.vimrc*
.zshrc

vim -c 'PluginInstall' -c 'qa!'
