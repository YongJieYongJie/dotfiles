# fzf-helpers.sh contains helper functions and keybindings for Git and FZF
# (with preview support):
#  - Ctrl-G Ctrl-F -> files
#  - Ctrl-G Ctrl-B -> branches
#  - Ctrl-G Ctrl-T -> tags
#  - Ctrl-G Ctrl-H -> hashes
#  - Ctrl-G Ctrl-R -> remotes
#  - Ctrl-G Ctrl-S -> stash
#
# After triggering the above, press Ctrl-Space to toggle press, Tab to toggle
# selection.

# From https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236

# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

_fzf_gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

_fzf_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

_fzf_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

_fzf_gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_fzf_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

_fzf_gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

if [[ -n $ZSH_VERSION ]]; then
  join-lines() {
    local item
    while read item; do
      echo -n "${(q)item} "
    done
  }

  _setup_keybinds() {
    local c
    for c in $@; do
      eval "fzf-g$c-widget() { local result=\$(_fzf_g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
      eval "zle -N fzf-g$c-widget"
      eval "bindkey '^g^$c' fzf-g$c-widget"
    done
  }
  _setup_keybinds f b t r h s

elif [[ -n $BASH_VERSION ]]; then
  bind '"\er": redraw-current-line'
  bind '"\C-g\C-f": "$(_fzf_gf)\e\C-e\er"'
  bind '"\C-g\C-b": "$(_fzf_gb)\e\C-e\er"'
  bind '"\C-g\C-t": "$(_fzf_gt)\e\C-e\er"'
  bind '"\C-g\C-h": "$(_fzf_gh)\e\C-e\er"'
  bind '"\C-g\C-r": "$(_fzf_gr)\e\C-e\er"'
  bind '"\C-g\C-s": "$(_fzf_gs)\e\C-e\er"'
fi

