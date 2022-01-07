#!/usr/bin/env sh

CI_PASSWORD="$1"

if [ "$os" = "Linux" ]; then
  # Assume it's a distribution that uses apt for package management (i.e.,
  # Debian-based distribution).
  sudo apt-get update
  command -v git  > /dev/null || sudo apt-get install -y git
  command -v curl > /dev/null || sudo apt-get install -y curl
  command -v fzf  > /dev/null || sudo apt-get install -y fzf

  # TODO: Also consider installing the following to set up keyboard/mouse
  # macros: xclip, x11-xserver-utils, xdotool, xmodmap

elif [ "$os" = "Darwin" ]; then
  xcode-select --print-path > /dev/null \
    || ${DOTFILES_INSTALLERS_DIR}/install-xcode.sh "$CI_PASSWORD"

  brew update
  HOMEBREW_NO_AUTO_UPDATE_ORIG=$HOMEBREW_NO_AUTO_UPDATE
  export HOMEBREW_NO_AUTO_UPDATE=1
  command -v git       > /dev/null || brew install git
  command -v curl      > /dev/null || brew install curl
  command -v fzf       > /dev/null || brew install fzf

  command -v gdircolors > /dev/null || brew install coreutils
  command -v gsed       > /dev/null || brew install gnu-sed
  export HOMEBREW_NO_AUTO_UPDATE=$HOMEBREW_NO_AUTO_UPDATE_ORIG

  # TODO: Also consider installing the following to set up keyboard/mouse
  # macros: yabai, shkd, karabiner

fi

settingsFilePath=${HOME}/.gitconfig
settingsLinkTarget=${DOTFILES_INSTALLERS_DIR}/home/.gitconfig
echo "[*] Creating a symlink at $settingsFilePath pointing to $settingsLinkTarget"
if test -f "$settingsFilePath" || test -L "$settingsLinkTarget"; then
    backupFile=$settingsFilePath.bak.`date +%Y%^b%d_%H%M`
    echo "[!] $settingsFilePath already exist, backing up to $backupFile"
    mv "$settingsFilePath" "$backupFile"
fi
ln -s "$settingsLinkTarget" "$settingsFilePath"

# Install Git prompt for Git-related information in prompt shell.
curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > ~/.git-prompt.sh

