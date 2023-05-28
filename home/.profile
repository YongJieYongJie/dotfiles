# Note: Generally, .profile is always loaded, and should contain things like
# environment variables and general aliases. The .zshrc and .bashrc should
# contain shell-specific items; also, they may not be loaded by programs like
# tmux, so we are sourcing it here.

PROFILE_LOADED=true

if [ -n "$ZSH_VERSION" ] && [ -z $ZSHRC_LOADED ]; then
  source "$HOME/.zshrc"
fi
if [ -n "$BASH" ] && [ -z $BASHRC_LOADED ]; then
  source "$HOME/.bashrc"
fi

# Set PATH so it includes user's private bin if it exists.
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi


######################################
# Sensible Defaults for Common Tools #
######################################

# Customize default behavior of less command.
LESS='--ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS --chop-long-lines'

# Asks before deleting/overwriting files / directories.
alias rm='rm -i -v'
alias cp='cp -i -v'
alias mv='mv -i -v'

## Listing files
if [[ $(uname -s) == "Darwin" ]]; then
  # Because macOS uses stupid BSD-based ls, and doesn't
  # support meaningful long parameters.
  alias ls='ls -hGF'

  alias l='ls'
  alias la='l -A'
  alias ll='l -l '
  alias lla='ll -A'

  # Sort by size, time
  alias lss='ls -s'
  alias lst='ls -t'

  alias lls='ll -s'
  alias llas='lla -s'
  alias llt='ll -t'
  alias llat='lla -t'
else
  alias ls='ls --classify --color=tty'

  # Basic listing
  alias l='ls'
  alias la='l --almost-all'

  # Long listing
  alias ll='l -l --size --human-readable'
  alias lla='ll --almost-all'

  # Sort by size, time
  alias lls='ll --sort=size'
  alias llas='lla --sort=size'
  alias llt='ll --sort=time'
  alias llat='lla --sort=time'
fi

# Navigation
alias p='pwd'
alias ..='cd ../'
alias ...='cd ../../'
alias c='clear'

# Searching
alias egrep='grep --extended-regexp'
alias fgrep='grep --fixed-strings --ignore-case'

# Misc
alias j='jobs'
alias n='nvim'

# Set EDITOR to nvim if not already set
[ -z "${EDITOR}" ] && export EDITOR='nvim'


#################
# Tools Related #
#################

## lf - Terminal File Manager (https://github.com/gokcehan/lf)
# Enables lfcd alias that runs lf, but also changes directory upon exit.
LFCD="$HOME/.config/lf/lfcd.sh"
if [ -f "$LFCD" ]; then
  source $LFCD
fi

## ripgrep (https://github.com/BurntSushi/ripgrep)
# Default to using smart case.
alias rg='rg --smart-case'

# Load lscolors so different filetypes have different color in output of
# commands like ls and lf
[ -f ~/.local/share/lscolors.sh ] && source ~/.local/share/lscolors.sh

# Load FZF Git helper funcions and keybindings
[ -f ~/.local/scripts/fzf-helpers.sh ] && source ~/.local/scripts/fzf-helpers.sh

# Use TwoDark theme for bat (replacement for cat) to match Neovim's color
# scheme.
export BAT_THEME=TwoDark

# Source asdf cross-language version manager (something like nvm and rvm).
[ -f ~/.asdf/asdf.sh ] && source ~/.asdf/asdf.sh


#################################
# Programming Language Related #
#################################

# Note: The paths in this section are just default locations, use the local
# override section to override as necessary.

## Go
export PATH="/usr/local/go/bin:$PATH" # add the Go binary itself to PATH
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH" # add the binaries installed by Go to PATH

## Rust
source "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$PATH"

## Java
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


###################
# Local Overrides #
###################

# Source machine-specific profile if exists.
if [ -f "$HOME/.local/profile" ]; then
  source "$HOME/.local/profile"
fi

