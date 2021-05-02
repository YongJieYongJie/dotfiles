#!/usr/bin/env bash

set -e

# This install-essential.sh script builds, installs and/or configures
# Neovim and some other commandline tools that are essential for a
# minimally productive experience using Neovim for software
# development.

# neovim_git_repo_dir is where Neovim's source code will be cloned
# into.
neovim_git_repo_dir="${HOME}/git-repos/neovim"

# neovim_install_dir is where Neovim will be installed to.
neovim_install_dir="${HOME}/local/nvim"

# Quit if Go is not installed.
command -v go >/dev/null 2>&1 || \
  { printf >&2 '\n[*] Please ensure Go is installed and the binary is available
    on $PATH. Aborting.\n'; exit 1; }

# Quit if Go version is not 1.16
go_version=$(go version | grep --only-match 'go[1-9]\+.[0-9]\+')
if [[ ${go_version##go1.} -lt 16 ]]; then
  printf >&2 '\n[*] Please ensure Go version 1.16 or greater installed. Aborting.\n'
  exit 1
fi


###################
# Building Neovim #
###################

printf '\n[*] Building Neovim\n'
# Links on how to build Neovim from source:
#  - https://github.com/neovim/neovim#install-from-source
#  - https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites
#  - https://github.com/neovim/neovim/wiki/Building-Neovim#building

# Create directory and clone the Neovim repository.
mkdir -p "${neovim_git_repo_dir}"
printf '\n[1/4] Cloning from https://github.com/neovim/neovim.git\n'
git clone https://github.com/neovim/neovim.git "${neovim_git_repo_dir}/neovim" \
  || printf "\n${neovim_git_repo_dir} already exists, not cloning again.\n"

# Install prerequisites for building Neovim
# Temporarily disable homebrew's auto-update
HOMEBREW_NO_AUTO_UPDATE_ORIG=${HOMEBREW_NO_AUTO_UPDATE}
HOMEBREW_NO_AUTO_UPDATE=1
printf '\n[2/4] Updating homebrew\n'
brew update
printf '\n[3/4] Installing prerequisites for building Neovim\n'
brew list ninja 2>/dev/null || brew install ninja
brew list libtool 2>/dev/null || brew install libtool
brew list automake 2>/dev/null || brew install automake
brew list cmake 2>/dev/null || brew install cmake
brew list pkg 2>/dev/null || brew install pkg-config
brew list gettext 2>/dev/null || brew install gettext

# Configure and build Neovim
printf '\n[4/4] Actually building Neovim\n'
cd "${neovim_git_repo_dir}/neovim"
make CMAKE_BUILD_TYPE=RelWithDebInfo
make CMAKE_INSTALL_PREFIX="${neovim_install_dir}" install


################################
# Neovim Plugins and Extenions #
################################

printf '\n[*] Setting up plugins and extensions for Neovim\n'

# Configure Neovim by copying over a configuration file (i.e., the
# init.vim) containing the essential plugins, extensions and settings.
# 
# Refer to comments within the init.vim file for details on the
# various plugins and extensions installed.
printf '\n[1/5] Copying configuration file for Neovim: init.vim\n'
nvimConfigFilePath=${HOME}/.config/nvim/init.vim
if test -f "$nvimConfigFilePath"; then
    backupFile=$nvimConfigFilePath.bak.`date +%Y%m%d_%H%M`
    printf "\n[!] $nvimConfigFilePath already exist, backing up to $backupFile\n"
    mv "$nvimConfigFilePath" "$backupFile"
fi
curl -fsSL https://github.com/YongJieYongJie/dotfiles/raw/commandline-essentials/init.vim > ${nvimConfigFilePath}

printf '\n[2/5] Copying configuration file for the coc plugin: coc-settings.json\n'
nvimCocSettingsFilePath=${HOME}/.config/nvim/coc-settings.json
if test -f "$nvimCocSettingsFilePath"; then
    backupFile=$nvimCocSettingsFilePath.bak.`date +%Y%m%d_%H%M`
    printf "\n[!] $nvimCocSettingsFilePath already exist, backing up to $backupFile\n"
    mv "$nvimCocSettingsFilePath" "$backupFile"
fi
curl -fsSL https://github.com/YongJieYongJie/dotfiles/raw/commandline-essentials/coc-settings.json > ${nvimCocSettingsFilePath}

# Install vim-plug the plugin manager for Vim / Neovim
#
# Home page:
#  - https://github.com/junegunn/vim-plug
# Installation instruction:
#  - https://github.com/junegunn/vim-plug#neovim
printf '\n[3/5] Installing Neovim plugin manager: vim-plug\n'
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
     --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Alias nv to the actual Neovim executable.
alias nv="${neovim_install_dir}/bin/nvim"

# Installing tools that cannot be installed from within Neovim, but
# are required for the plugins / extensions to work.
#
# Relevant links for the various tools:
#  - https://github.com/junegunn/fzf#using-homebrew
#  - https://github.com/junegunn/fzf.vim#installation
#  - https://github.com/BurntSushi/ripgrep
#  - https://github.com/junegunn/fzf.vim#dependencies
printf '\n[4/5] Installing prerequisites for Neovim extensions\n'
brew list node 2>/dev/null || brew install node
brew list bat 2>/dev/null || brew install bat
brew list ripgrep 2>/dev/null || brew install ripgrep
brew list fzf 2>/dev/null || brew install fzf

# Start Neovim, run the ':PlugInstall' command to install plugins, and
# the quit using the ':qa!' command.
printf '\n[5/5] Installing Neovim extensions\n'
${neovim_install_dir}/bin/nvim -c 'PlugInstall' -c 'qa!'


################################################
# Installing Quality-of-Life Commandline Tools #
################################################

printf '\n[*] Installing quality-of-life commandline tools\n'

# FZF - commandline fuzzy finder
#
# Home page:
#  - https://github.com/junegunn/fzf
# Useful links:
#    https://github.com/junegunn/fzf#key-bindings-for-command-line
printf '\n[1/4] Installing FZF - commandline fuzzy finder\n'
brew list fzf || brew install fzf

# To install useful key bindings and fuzzy completion:
printf '\n[!] You will now be prompted to update your settings to enable keybindings for
    your default shell (usually bash or zsh):\n'
$(brew --prefix)/opt/fzf/install


# LF - commandline file browser
#
# Home page
#  - https://github.com/gokcehan/lf
# Useful links:
#  - https://github.com/gokcehan/lf/wiki/Tutorial#basics
#  - https://github.com/gokcehan/lf/wiki/Integrations
#
# Installation:
#  - https://github.com/gokcehan/lf/wiki/Packages#homebrew
printf '\n[2/4] Installing LF - commandline file browser\n'
brew list lf >/dev/null 2>&1 || brew install lf

# Pistol - commandline file previewer with syntax highlighting
#
# Home page
#  - https://github.com/doronbehar/pistol
# Installation instructions:
#  - https://github.com/doronbehar/pistol#install
# Prerequisites:
#  - https://github.com/rakyll/magicmime/tree/v0.1.0#prerequisites
#  - https://github.com/rakyll/magicmime/tree/v0.1.0#usage
printf '\n[3/4] Installing Pistol - file previewer\n'
brew list libmagic || brew install libmagic
go get github.com/rakyll/magicmime
env GO111MODULE=on go get -u github.com/doronbehar/pistol/cmd/pistol

# Configuring LF to use Pistol for file previews
mkdir -p ${HOME}/.config/lf

printf '\n[4/4] Copying configuration files for LF: lfrc and lfcd.sh\n'
lfConfigFilePath=${HOME}/.config/lf/lfrc
if test -f "$lfConfigFilePath"; then
    backupFile=$lfConfigFilePath.bak.`date +%Y%m%d_%H%M`
    printf "\n[!] $lfConfigFilePath already exist, backing up to $backupFile\n"
    mv "$lfConfigFilePath" "$backupFile"
fi
curl -fsSL https://github.com/YongJieYongJie/dotfiles/raw/commandline-essentials/lfrc > ${lfConfigFilePath}

lfcdScriptFilePath=${HOME}/.config/lf/lfcd.sh
if test -f "$lfcdScriptFilePath"; then
    backupFile=$lfcdScriptFilePath.bak.`date +%Y%m%d_%H%M`
    printf "\n[!] $lfcdScriptFilePath already exist, backing up to $backupFile\n"
    mv "$lfcdScriptFilePath" "$backupFile"
fi
curl -fsSL https://github.com/YongJieYongJie/dotfiles/raw/commandline-essentials/lfcd.sh > ${lfcdScriptFilePath}


# Restore homebrew's auto-update setting
HOMEBREW_NO_AUTO_UPDATE=${HOMEBREW_NO_AUTO_UPDATE_ORIG}

##################################################
# Additional configurations for .bashrc / .zshrc #
##################################################

echo "
[!] Add the following lines to ~/.bashrc, ~/.zshrc, or ~/.profile file as 
    appropriate (try until you find one that works, or read the man pages for
    your shell of choice to understand which files are loaded on start-up):

# Alias nv to the actual Neovim executable.
alias nv="${neovim_install_dir}/bin/nvim"

# Use Neovim as the default editor for various command-line tools
export EDITOR="\${HOME}/local/nvim/bin/nvim"

# Make FZF UI slightly prettier
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Enable using \`lfcd\` to browse and change directory
LFCD="\${HOME}/.config/lf/lfcd.sh"
if [ -f "\$LFCD" ]; then
    source "\$LFCD"
fi
"

printf '\n[*] All done! Copy the lines above to your ~/.bashrc or ~/.zshrc file, restart
    your shell, and run `nv` to start your Neovim journey at Ninja Van.\n'

printf '\n[*] You might also want to enable running VSCode directly from the shell by
    first opening VSCode and select "Shell Command: install code command in
    PATH" from the Command Palette\n'

