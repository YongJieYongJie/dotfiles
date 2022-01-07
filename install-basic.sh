#!/usr/bin/env sh

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
    ${DOTFILES_INSTALLERS_DIR}/install-xcode.sh
    ${DOTFILES_INSTALLERS_DIR}/install-brew.sh

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

. "${DOTFILES_INSTALLERS_DIR}/lib/sh/helpers.sh"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/home/.gitconfig" "${HOME}/.gitconfig"

# Install Git prompt for Git-related information in prompt shell.
curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
     > ${HOME}/.git-prompt.sh

