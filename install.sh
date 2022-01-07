#!/usr/bin/env sh

scriptDir=`dirname "$0"`
DOTFILES_INSTALLERS_DIR=`cd $scriptDir;pwd`
homeDir=${HOME:-~}

echo "[*] Executing installation script located at ${DOTFILES_INSTALLERS_DIR}..."

# --------------------------------------- Install commonly-used binaries -------

if [ "$os" = "Linux" ]; then
  # ------------------------------------------- Install apt-related tools ------
  # Assume it's a distribution that uses apt for package management (i.e.,
  # Debian-based distribution).
  sudo apt-get update
  # sudo apt-get upgrade
  sudo apt-get install -y \
    tmux \
    git \
    curl \
    fzf
    # xclip \
    # x11-xserver-utils \
    # xdotool
    # xmodmap

  # ------------------------------------------ Install dpkg-related tools ------

  # ------------------------------------------ Install Rust-related tools ------
  # Install rustup using instructions from
  # https://www.rust-lang.org/learn/get-started.
  # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  # -------------------------------------------- Install Go-related tools ------

  . "${DOTFILES_INSTALLERS_DIR}"/install-go.sh

  command -v go && hasGo="true"
  if [ -z "$hasGo" ]; then

    printf "[!] Go binary not found/installed. Skipping installation that\n"
    printf "    requires Go."
  else
    # Based on instructions at https://github.com/gokcehan/lf#installation.
    env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest

    # Based on instructions at env CGO_ENABLED=1 GO111MODULE=on go get -u
    # github.com/doronbehar/pistol/cmd/pistol.
    command -v apt-get && sudo apt-get install -y gcc libmagic-dev
    env CGO_ENABLED=1 GO111MODULE=on go get -u github.com/doronbehar/pistol/cmd/pistol
  fi

elif [ "$os" = "Darwin" ]; then

  PASSWORD="$1"
  xcode-select --print-path || ${DOTFILES_INSTALLERS_DIR}/install-xcode.sh "$PASSWORD"

  brew update
  export HOMEBREW_NO_AUTO_UPDATE=1
  command -v tmux      > /dev/null || brew install tmux
  command -v git       > /dev/null || brew install git
  command -v curl      > /dev/null || brew install curl
  command -v fzf       > /dev/null || brew install fzf
  command -v lf        > /dev/null || brew install lf

  command -v gdircolors > /dev/null || brew install coreutils
  command -v gsed       > /dev/null || brew install gnu-sed

else
  printf "[!] Install script does not work on $os"
  exit 1
fi

# ------------------------------------------------- Set up configurations ------

for dotfile in .gitconfig .profile .tmux.conf .bashrc
do
    echo "[*] Creating a symlink at $homeDir/$dotfile pointing to ${DOTFILES_INSTALLERS_DIR}/home/$dotfile..."
    if test -f "$homeDir/$dotfile" || test -L "$homeDir/$dotfile"; then
        backupFile=$dotfile.bak.`date +%Y%m%d_%H%M`
        echo "[!] $dotfile already exist at $homeDir, backing up to $backupFile"
        mv "$homeDir/$dotfile" "$homeDir/$backupFile"
    fi
    ln -s "${DOTFILES_INSTALLERS_DIR}/home/$dotfile" "$homeDir/$dotfile"
done

# Install Git prompt for Git-related information in prompt shell.
curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/.git-prompt.sh

