# The following lines were added by compinstall
zstyle :compinstall filename '/home/YongJie/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# ========================
# things added by Yong Jie
# ========================

# includes
source ~/.git-prompt.sh

# zsh optionns
setopt MENU_COMPLETE
setopt NO_LIST_BEEP

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

# needed because ruby is not installed under cygwin but natively to windows
alias gem='D:/Ruby22/bin/gem'
alias rspec='D:/Ruby22/bin/rspec'

# miscellaneous
alias grep='grep --color'
