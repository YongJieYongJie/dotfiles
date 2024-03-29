ZSHRC_LOADED=true

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# For a comprehensive overview of how to optimize start-up time, refer to
# https://htr3n.github.io/2018/07/faster-zsh/.

# The plugin manager used is Zinit, and the recommended way to install is as
# follows (at
# https://github.com/zdharma-continuum/zinit#automatic-installation-recommended):
#     sh -c "$(curl -fsSL https://git.io/zinit-install)"


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

# zsh options
setopt MENU_COMPLETE
setopt NO_LIST_BEEP
setopt NO_BEEP
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Don't highlight pasted text (makes it difficult to see cursor)
zle_highlight+=(paste:none)

# prompt string
#setopt PROMPT_SUBST;
#
PS1='
[%Th] %F{green}%n@%m%f %F{yellow}%~%f%F{blue}$(__git_ps1)%f
$ '

[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] \
  && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load utility script for handling huge number of tmux panes
[ -f ~/.local/scripts/tmux-go-to-pane-install-widget.zsh ] \
  && source ~/.local/scripts/tmux-go-to-pane-install-widget.zsh

# configure fzf fuzzy finder to popup below
FZF_DEFAULT_OPTS='--height 40% --layout=reverse
--bind=ctrl-n:down,ctrl-p:up
--bind=ctrl-v:page-down,alt-v:page-up
--bind=ctrl-d:preview-page-down,ctrl-u:preview-page-up
--bind=alt-p:previous-history,alt-n:next-history
--bind=ctrl-n:down,ctrl-p:up
--bind=shift-tab:toggle-all
--bind=ctrl-k:kill-line
--bind="ctrl-alt-c:preview(cat {})"
--bind="ctrl-alt-l:preview(ls -lAh {})"
--bind=alt-enter:print-query
--bind=ctrl-space:toggle-preview
--bind=ctrl-alt-w:toggle-preview-wrap
--preview-window hidden
--history='$HOME'/.fzf-history'

# Add catpuccin-frappe theme, from https://github.com/catppuccin/fzf
FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284'

export FZF_DEFAULT_OPTS
# --color=light'
[ -f ~/.fzf-history ] || touch ~/.fzf-history

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit ice depth=1
zinit light romkatv/powerlevel10k

# Copied from https://zdharma.org/zinit/wiki/Example-Minimal-Setup/
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

# From https://www.reddit.com/r/zinit/comments/rqlb8n/comment/hqe7k3w/?utm_source=share&utm_medium=web2x&context=3
export NVM_COMPLETION=true
export NVM_SYMLINK_CURRENT="true"
zinit wait lucid light-mode for lukechilds/zsh-nvm

# Set the autosuggestion color, actual color depends on color scheme and may
# need testing different number.
export TERM=xterm-256color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Remove the forward slash and hyphen characters from what is considered part
# of a word so meta+f and meta+b will stop at directory boundaries.
WORDCHARS=${WORDCHARS//[\/-]}
WORDCHARS=${WORDCHARS//[?.&]}

# Case-insensitve completion. Copied from
# https://stackoverflow.com/a/24237590/5821101.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Restore ability to use meta-b to move backwards by a single word (and similar
# functions) in IntelliJ and Neovim terminal. Adapted from
# https://youtrack.jetbrains.com/issue/IDEA-165184/Add-Use-Option-as-Meta-key-support-to-terminal#focus=Comment-27-4882607.0-0
if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]] || [[ -n "$$NVIM" ]]; then
    bindkey "ƒ" forward-word
    bindkey "∫" backward-word
    bindkey "∂" kill-word
    # bindkey "¬" downcase-word
    bindkey "ç" capitalize-word
    bindkey "†" transpose-words
    bindkey "≥" insert-last-word
    # bindkey "¨ " upcase-word
fi

[ -f ~/.profile ] && [ -z $PROFILE_LOADED ] && source ~/.profile

