#!/usr/bin/env sh

scriptDir=`dirname "$0"`
absScriptDir=`cd $scriptDir;pwd`
homeDir=~

echo "[*] Executing installation script located at `dirname "$0"`..."

# --------------------------------------- Install commonly-used binaries -------

os=$(uname | tr '[:upper:]' '[:lower:]')

if [ "$os" = "linux" ]; then
  # ------------------------------------------- Install apt-related tools ------
  # Assume it's a distribution that uses apt for package management (i.e.,
  # Debian-based distribution).
  sudo apt-get update
  # sudo apt-get upgrade
  sudo apt-get install -y \
    zsh \
    tmux \
    git \
    vim \
    neovim \
    emacs \
    fzf \
    bat \
    xclip \
    xdotool \
    xmodmap

  # -------------------------------------------- Install Go-related tools ------

  "$absScriptDir"/install-go.sh

  command -v go && hasGo="true"
  if [ -z "$hasGo" ]; then
    printf "[!] Go binary not found/installed. Skipping installation that"
    printf "    requires Go."
  else
    # Based on instructions at https://github.com/gokcehan/lf#installation
    env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest
  fi

  # ------------------------------------------- Install npm-related tools ------
  # Install nvm, as recommended by npm (at
  # https://docs.npmjs.com/downloading-and-installing-node-js-and-npm), and
  # following instructions from nvm (at
  # https://github.com/nvm-sh/nvm#manual-install)
  export NVM_DIR="$HOME/.nvm" && (
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" \
      $(git rev-list --tags --max-count=1)`
  ) && \. "$NVM_DIR/nvm.sh"

  nvm install node && nvm use node
  npm install -g yarn

  # TODO: Add installation commands for Darwin
  # elif [ "$os" = "darwin" ]; then

else
  printf "[!] Install script does not work on $os"
  exit 1
fi

# ------------------------------------------------- Set up configurations ------

for dotfile in .gitconfig .profile .tmux.conf .vimrc .zshrc
do
    echo "[*] Creating a symlink at $homeDir/$dotfile pointing to $absScriptDir/home/$dotfile..."
    if test -f "$homeDir/$dotfile" || test -L "$homeDir/$dotfile"; then
        backupFile=$dotfile.bak.`date +%Y%m%d_%H%M`
        echo "[!] $dotfile already exist at $homeDir, backing up to $backupFile"
        mv "$homeDir/$dotfile" "$homeDir/$backupFile"
    fi
    ln -s "$absScriptDir/home/$dotfile" "$homeDir/$dotfile"
done

# Symlinking Neovim's configuration and coc's settings
mkdir -p $homeDir/.config/nvim
nvimConfigFilePath=$homeDir/.config/nvim/init.vim
nvimConfigLinkTarget=$absScriptDir/init.vim
echo "[*] Creating a symlink at $nvimConfigFilePath pointing to $nvimConfigLinkTarget"
if test -f "$nvimConfigFilePath" || test -L "$nvimConfigLinkTarget"; then
    backupFile=$nvimConfigFilePath.bak.`date +%Y%m%d_%H%M`
    echo "[!] $nvimConfigFilePath already exist, backing up to $backupFile"
    mv "$nvimConfigFilePath" "$backupFile"
fi
ln -s "$nvimConfigLinkTarget" "$nvimConfigFilePath"

nvimCocSettingsFilePath=$homeDir/.config/nvim/coc-settings.json
nvimCocSettingsLinkTarget=$absScriptDir/coc-settings.json
echo "[*] Creating a symlink at $nvimCocSettingsFilePath pointing to $nvimCocSettingsLinkTarget"
if test -f "$nvimCocSettingsFilePath" || test -L "$nvimCocSettingsLinkTarget"; then
    backupFile=$nvimCocSettingsFilePath.bak.`date +%Y%^b%d_%H%M`
    echo "[!] $nvimCocSettingsFilePath already exist, backing up to $backupFile"
    mv "$nvimCocSettingsFilePath" "$backupFile"
fi
ln -s "$nvimCocSettingsLinkTarget" "$nvimCocSettingsFilePath"

# Install plugin manager for Neovim.
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Install plugins for Neovim.
nvim -c 'PluginInstall' -c 'qa!'

# Install plugin manager for Vim.
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Install plugins for Vim.
vim -c 'PluginInstall' -c 'qa!'

# Symlinking Emacs's configuration
mkdir -p $homeDir/.emacs.d
emacsConfigFilePath=$homeDir/.emacs.d/init.el
emacsConfigLinkTarget=$absScriptDir/init.el
echo "[*] Creating a symlink at $emacsConfigFilePath pointing to $emacsConfigLinkTarget"
if test -f "$emacsConfigFilePath" || test -L "$emacsConfigLinkTarget"; then
    backupFile=$emacsConfigFilePath.bak.`date +%Y%m%d_%H%M`
    echo "[!] $emacsConfigFilePath already exist, backing up to $backupFile"
    mv "$emacsConfigFilePath" "$backupFile"
fi
ln -s "$emacsConfigLinkTarget" "$emacsConfigFilePath"

# Install Git prompt for Git-related information in prompt shell.
curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/.git-prompt.sh

# Install package manager for zsh: Zinit. Instructions from
# https://github.com/zdharma-continuum/zinit#automatic-installation-recommended.
sh -c "$(curl -fsSL https://git.io/zinit-install)"

# Install lscolors so different filetypes have different color in output of
# commands like ls and lf. Based on instructions at
# https://github.com/trapd00r/LS_COLORS#installation.
mkdir /tmp/LS_COLORS \
  && curl -L https://api.github.com/repos/trapd00r/LS_COLORS/tarball/master \
  | tar xzf - --directory=/tmp/LS_COLORS --strip=1
( cd /tmp/LS_COLORS && sh install.sh )
