#!/usr/bin/env sh

set -e

scriptDir=$(dirname "$0")
export DOTFILES_INSTALLERS_DIR=$(cd $scriptDir;pwd)
export os=$(uname)

printf "[*] Executing installation script located at ${DOTFILES_INSTALLERS_DIR}...\n"
printf "[*] OS is $os\n"

printf "[*] Installing basic OS tools...\n"
${DOTFILES_INSTALLERS_DIR}/install-basic.sh

printf "[*] Installing Go...\n"
. ${DOTFILES_INSTALLERS_DIR}/install-go.sh
printf "[*] Installing nvm, nodejs and yarn...\n"
. ${DOTFILES_INSTALLERS_DIR}/install-node-related.sh

printf "[*] Installing tmux...\n"
${DOTFILES_INSTALLERS_DIR}/install-tmux.sh
printf "[*] Installing zsh...\n"
${DOTFILES_INSTALLERS_DIR}/install-zsh.sh

printf "[*] Installing lf...\n"
${DOTFILES_INSTALLERS_DIR}/install-lf.sh
printf "[*] Installing bat...\n"
${DOTFILES_INSTALLERS_DIR}/install-bat.sh
printf "[*] Installing pistol...\n"
# ${DOTFILES_INSTALLERS_DIR}/install-pistol.sh
printf "[*] Installing git-delta...\n"
${DOTFILES_INSTALLERS_DIR}/install-git-delta.sh
printf "[*] Installing trapd00r/LS_COLORS...\n"
# ${DOTFILES_INSTALLERS_DIR}/install-lscolors.sh

printf "[*] Installing Emacs...\n"
${DOTFILES_INSTALLERS_DIR}/install-emacs.sh
printf "[*] Installing Neovim...\n"
${DOTFILES_INSTALLERS_DIR}/install-neovim.sh
