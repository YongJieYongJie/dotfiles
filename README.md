# yongjieyongjie's dotfiles

Dotfiles and other configuration files for the various tools I use.

## Design concept

Files checked into the repository should be generally applicable
across machines. In other words, machine-specific dotfiles and
configurations should reside only on the applicable machines, and be
loaded by the files in this repository (see for example how  `.zshrc`
loads `~/.profile`.
