#!/usr/bin/env sh

scriptDir=`dirname "$0"`
absScriptDir=`cd $scriptDir;pwd`
homeDir=${HOME:-~}

echo "[*] Executing installation script located at $absScriptDir..."

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
    curl \
    vim \
    neovim \
    emacs \
    fzf \
    bat
    # xclip \
    # x11-xserver-utils \
    # xdotool
    # xmodmap

  # ------------------------------------------ Install dpkg-related tools ------

  deltaUrl=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
    | grep -E 'browser_download_url.*amd64\.deb' \
    | grep -v musl \
    | cut -d\" -f4)
  curl -LO $deltaUrl
  deltaFilename=${deltaUrl##*/}
  sudo dpkg -i $deltaFilename
  rm $deltaFilename

  batUrl=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
    | grep -E 'browser_download_url.*amd64\.deb' \
    | grep -v musl \
    | cut -d\" -f4)
  curl -LO $batUrl
  batFilename=${batUrl##*/}
  sudo dpkg -i $batFilename
  rm $batFilename

  # ------------------------------------------ Install Rust-related tools ------
  # Install rustup using instructions from
  # https://www.rust-lang.org/learn/get-started.
  # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  # -------------------------------------------- Install Go-related tools ------

  . "$absScriptDir"/install-go.sh

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

  # ------------------------------------------- Install npm-related tools ------
  # Install nvm, as recommended by npm (at
  # https://docs.npmjs.com/downloading-and-installing-node-js-and-npm), and
  # following instructions from nvm (at
  # https://github.com/nvm-sh/nvm#manual-install)
  [ -d $homeDir/.nvm ] && hasNvm="true"
  if [ -z "$hasNvm" ]; then
    export NVM_DIR="$HOME/.nvm" && (
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" \
      $(git rev-list --tags --max-count=1)`
          ) && \. "$NVM_DIR/nvm.sh"

          nvm install node && nvm use node
          npm install -g yarn
  fi

elif [ "$os" = "darwin" ]; then

  PASSWORD="$1"
  xcode-select --print-path || $absScriptDir/install-xcode.sh "$PASSWORD"

  command -v brew > /dev/null && hasBrew="true"
  if [ -z "$hasBrew" ]; then
		# HOMEBREW_PREFIX="/usr/local"
		# HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
		# HOMEBREW_CORE="${HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-core"

		# HOMEBREW_BREW_DEFAULT_GIT_REMOTE="https://github.com/Homebrew/brew"
		# HOMEBREW_CORE_DEFAULT_GIT_REMOTE="https://github.com/Homebrew/homebrew-core"

    # printf "[*] creating HOMEBREW_REPOSITORY\n"
    # echo "$PASSWORD\n" | sudo -S rm -rf ${HOMEBREW_REPOSITORY}
    # echo "$PASSWORD\n" | sudo -S mkdir -p ${HOMEBREW_REPOSITORY}
    # echo "$PASSWORD\n" | sudo -S chown -R $(id -u):$(id -g) ${HOMEBREW_REPOSITORY}
    # printf "[*] cloning HOMEBREW_REPOSITORY\n"
		# [ -d "${HOMEBREW_REPOSITORY}/.git" ] || git clone ${HOMEBREW_BREW_DEFAULT_GIT_REMOTE} ${HOMEBREW_REPOSITORY}
    # printf "[*] ls HOMEBREW_REPOSITORY\n"
    # ls -lA ${HOMEBREW_REPOSITORY}

    # printf "[*] creating HOMEBREW_CORE\n"
    # echo "$PASSWORD\n" | sudo -S mkdir -p ${HOMEBREW_CORE}
    # echo "$PASSWORD\n" | sudo -S chown -R $(id -u):$(id -g) ${HOMEBREW_CORE}
    # printf "[*] cloning HOMEBREW_CORE\n"
		# [ -d "${HOMEBREW_CORE}/.git" ] || git clone ${HOMEBREW_CORE_DEFAULT_GIT_REMOTE} ${HOMEBREW_CORE}
    # printf "[*] ls HOMEBREW_CORE\n"
    # ls -lA ${HOMEBREW_CORE}

		# echo "$PASSWORD\n" | sudo -S mkdir -p ${HOMEBREW_PREFIX}/bin
    # echo "$PASSWORD\n" | sudo -S chown -R $(id -u):$(id -g) ${HOMEBREW_PREFIX}/bin
		# echo "$PASSWORD\n" | sudo -S ln -sf ${HOMEBREW_REPOSITORY}/bin/brew ${HOMEBREW_PREFIX}/bin/brew
		# export PATH=${PATH}:${HOMEBREW_REPOSITORY}/bin

    # echo "$PASSWORD\n" | sudo -S mkdir -p /usr/local/var/homebrew/locks
    # echo "$PASSWORD\n" | sudo -S chown -R $(id -u):$(id -g) /usr/local/var/homebrew
    # "${HOMEBREW_PREFIX}/bin/brew" "update" "--force" "--quiet"

    echo "$PASSWORD" | sudo -S touch ~/echo_password
    echo "$PASSWORD" | sudo -S sh -c "echo '#!/usr/bin/env sh\necho $PASSWORD' > ~/echo_password"

    echo "$PASSWORD" | sudo -S chown $(id -u):$(id -g) ~/echo_password
    cat ~/echo_password
    echo "$PASSWORD" | chmod +x ~/echo_password
    export SUDO_ASKPASS=~/echo_password
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # script "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # curl -fsSLO https://raw.githubusercontent.com/Homebrew/install/master/install.sh
    # printf "[*] ls -ls $(pwd):\n"
    # ls -lh
    # chmod +x ./install.sh
    # echo "alpine" | sudo -l
    # ./test-brew-bash.sh
		# sudo -n -l mkdir
		#TODO try sudo -n -l mkdir within ./test-brew-bash.sh to see whether works. if doesn't it is consistent with the brew install script. also try running it in this script, just before calling the test-brew-bash.sh
    # ./install.sh
  fi

  brew update
  export HOMEBREW_NO_AUTO_UPDATE=1
  command -v tmux      > /dev/null || brew install tmux
  command -v git       > /dev/null || brew install git
  command -v curl      > /dev/null || brew install curl
  command -v vim       > /dev/null || brew install vim
  command -v neovim    > /dev/null || brew install neovim
  command -v emacs     > /dev/null || brew install emacs
  command -v fzf       > /dev/null || brew install fzf
  command -v bat       > /dev/null || brew install bat
  command -v lf        > /dev/null || brew install lf
  command -v git-delta > /dev/null || brew install git-delta

  command -v gdircolors > /dev/null || brew install coreutils
  command -v gsed       > /dev/null || brew install gnu-sed

  # ------------------------------------------- Install npm-related tools ------
  # Install nvm, as recommended by npm (at
  # https://docs.npmjs.com/downloading-and-installing-node-js-and-npm), and
  # following instructions from nvm (at
  # https://github.com/nvm-sh/nvm#manual-install)
  export NVM_DIR="$HOME/.nvm" && (
    cd "$HOME"
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" \
      $(git rev-list --tags --max-count=1)`
  ) && \. "$NVM_DIR/nvm.sh"

  nvm install node && nvm use node
  npm install -g yarn

else
  printf "[!] Install script does not work on $os"
  exit 1
fi

# ------------------------------------------------- Set up configurations ------

for dotfile in .gitconfig .profile .tmux.conf .vimrc .zshrc .bashrc
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
curl -fLo $homeDir/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Install plugins for Neovim.
(cd $homeDir && nvim --headless -c 'PlugInstall' -c 'qa!')

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
echo "n" | sh -c "$(curl -fsSL https://git.io/zinit-install)"

# Install lscolors so different filetypes have different color in output of
# commands like ls and lf. Based on instructions at
# https://github.com/trapd00r/LS_COLORS#installation.
mkdir -p $homeDir/LS_COLORS \
  && curl -L https://api.github.com/repos/trapd00r/LS_COLORS/tarball/master \
  | tar xzf - --directory=$homeDir/LS_COLORS --strip=1

if [ "$os" = "darwin" ]; then
  gsed -i -e 's/\<dircolors\>/gdircolors/g ; s/\<mv\>/gmv/g' $homeDir/LS_COLORS/install.sh
fi
(cd $homeDir && $homeDir/LS_COLORS/install.sh && rm -rf $homeDir/LS_COLORS)
