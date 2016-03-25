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

let mapleader = ','

set history=512 " number of commands to remember in history
set number      " show line number
set wildmenu
set autoread    " automatically reads from file if modified outside of Vim
set cursorline  " highlights current line
set scrolloff=7 " keeps 7 line above and below current line when scrolling vertically
set hidden      " allow unsaved background
set backspace=eol,start,indent " allows backspacing through such characters
set whichwrap+=<,>,h,l,[,] " allows wrapping to next/prev lines when moving left and right

set showmatch   " show matching parenthesis etc.
set matchtime=2 " ??
set laststatus=2 " show airline

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

" Use spaces instead of tabs
set expandtab
" Be smart when using tabs ;)
set smarttab
" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
set softtabstop=4

set autoindent
set smartindent

set nowrap " don't wrap lines
" Use Unix as the standard file type
set ffs=unix,dos,mac

" Add a bit extra margin to the left
set foldcolumn=1

set ignorecase " ignores case when searching
set smartcase  " don't ignore case when searching if search term has uppercase
set hlsearch   " highligh search terms
set incsearch  " search while typing 
map <silent> <leader><cr> :noh<cr>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

try
  set switchbuf=useopen,usetab,newtab
  set showtabline=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

set noerrorbells " turn off bells
set novisualbell
set t_vb=

set lazyredraw " don't redrow while executing macros (for performance)

set wildignore=*.o,*~,*.pyc " ignores compile files
if has("win16") || has("win32") " ignores version control files
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

syntax enable
set background=dark
colorscheme solarized
