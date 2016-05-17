# The following lines were added by compinstall
zstyle :compinstall filename '/home/YongJie/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# ========================
# things added by Yong Jie
# ========================

# includes
source ~/.antigen.zsh
source ~/.git-prompt.sh

# plugin management using antigen
# Load the oh-my-zsh's library.
antigen use oh-my-zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# zsh optionns
setopt MENU_COMPLETE
setopt NO_LIST_BEEP
setopt NO_BEEP

# prompt string
setopt PROMPT_SUBST;

PS1='
%F{green}%n@%m%f %F{yellow}%~%f%F{blue}$(__git_ps1)%f
$ '

# asks before deleting/overwriting
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# listing
alias ls='ls -F --color=tty'
alias l='ls'
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

export EDITOR='/usr/bin/vim'

# source machine specific stuff (i.e., not on github dotfiles)
if [ -f "${HOME}/.profile" ]; then
    source "${HOME}/.profile"
fi
