# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# For a comprehensive overview of how to optimize start-up time, refer to
# https://htr3n.github.io/2018/07/faster-zsh/.

# The plugin manager used is Zinit, and the recommended way to install is as
# follows:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
#
# The above will install Zinit in ~/.zinit/bin. .zshrc will be updated with
# three lines of code that will be added to the bottom. The lines will be
# sourcing zinit.zsh and setting up completion for command zinit. After
# installing and reloading the shell compile Zinit with zinit self-update.


#zmodload zsh/zprof
# The following lines were added by compinstall
#autoload -Uz compinit
#compinit
# End of lines added by compinstall

# Set history file, and lines of history to keep in memory and to save
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=99999
export SAVEHIST=$HISTSIZE

# Use emacs style keybindings
bindkey -e

# Binds shift-tab to traverse auto-completion in reverse
bindkey '^[[Z' reverse-menu-complete


# includes
#source ~/.antigen.zsh
#source ~/.git-prompt.sh

# plugin management using antigen
# Load the oh-my-zsh's library.
#antigen use oh-my-zsh
#antigen bundle zsh-users/zsh-syntax-highlighting
#antigen apply

# zsh optionns
setopt MENU_COMPLETE
setopt NO_LIST_BEEP
setopt NO_BEEP

# prompt string
#setopt PROMPT_SUBST;
#
PS1='
[%Th] %F{green}%n@%m%f %F{yellow}%~%f%F{blue}$(__git_ps1)%f
$ '

source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# configure fzf fuzzy finder to popup below
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

zinit ice depth=1
zinit light romkatv/powerlevel10k

# Copied from https://zdharma.org/zinit/wiki/Example-Minimal-Setup/
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
      zdharma/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

# Set the autosuggestion color, actual color depends on color scheme and may
# need testing different number.
export TERM=xterm-256color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Remove the forward slash and hyphen characters from what is considered part
# of a word so meta+f and meta+b will stop at directory boundaries.
WORDCHARS=${WORDCHARS//[\/-]}

# Case-insensitve completion. Copied from
# https://stackoverflow.com/a/24237590/5821101.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
