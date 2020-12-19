# Note: Generally, .profile is always load, and should contain things like
# environment variables and general aliases. The .zshrc and .bashrc should
# contain shell-specific items; also, they may not be loaded by programs like
# tmux, so we are sourcing it here.

# Uncomment the relevant line as necessary.
# source "${HOME}/.bashrc"
source "${HOME}/.zshrc"

# Source machine-specific profile if exists.
if [ -f "${HOME}/.machine_specific_profile" ]; then
  source "${HOME}/.machine_specific_profile"
fi

# Search aliasing
alias 'ag=ag --ignore="*min.js" --ignore="*js.map" --ignore="*uploadify.js" --ignore="*bundle"'
alias rg='rg --smart-case'

# Customize default behavior of less command.
LESS='--ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS --chop-long-lines'

# Asks before deleting/overwriting files / directories.
alias rm='rm -i -v'
alias cp='cp -i -v'
alias mv='mv -i -v'

# listing
# alias ls='ls -F --color=tty'
alias l='ls -G'
alias la='ls -A'
alias ll='ls -hls'
alias lla='ll -Al'

# navigation related
alias p='pwd'
alias ..='cd ../'
alias ...='cd ../../'
alias c='clear'

# miscellaneous
alias egrep='grep --extended-regexp'
alias fgrep='grep --fixed-strings --ignore-case'
alias j='jobs'
alias n='nvim'

export EDITOR='nvim'

