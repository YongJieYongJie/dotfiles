set nocompatible              " be iMproved, required
filetype off                  " required

" use vundle to manage plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'wincent/command-t'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'powerline/fonts'
call vundle#end()
filetype plugin indent on

set number
set wildmenu

" show airline
set laststatus=2

syntax enable
set background=dark
colorscheme solarized
