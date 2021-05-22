# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


# ------ Small Quality-of-Life Improvements -----------------------------------

# Use case-insensitive filename globbing
shopt -s nocaseglob

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell


# ------ History-related ------------------------------------------------------

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well

# Whenever displaying the prompt, write the previous line to disk
export PROMPT_COMMAND="history -a"

# make tab cycle through commands after listing, from
# https://unix.stackexchange.com/a/527944
bind '"\t":menu-complete'
bind "set show-all-if-ambiguous on"
bind "set completion-ignore-case on"
bind "set menu-complete-display-prefix on"


# ------ Prompt String --------------------------------------------------------

RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
VIOLET="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
RESET="\[$(tput sgr0)\]"
export PS1="
${YELLOW}[\t]${RESET} ${CYAN}\W${RESET}${GREEN}\$(__git_ps1 \" (%s)\")${RESET}
\$ "


# ------ Completions ----------------------------------------------------------

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.git-prompt.sh ] && source ~/.git-prompt.sh
[ -f ~/.git-completion.bash ] && source ~/.git-completion.bash

