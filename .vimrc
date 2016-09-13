"" Instructions for first run:
"" - install vundle: git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"" - install plugins: inside vim, run :PluginInstall

set nocompatible              " be iMproved, required for vundle
filetype off                  " required for vundle

" use vundle to manage plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" ruby stuff
Plugin 'vim-ruby/vim-ruby'

" powershell stuff
" Plugin 'PProvost/vim-ps1'

" fuzzy file openers
Plugin 'wincent/command-t'
Plugin 'ctrlpvim/ctrlp.vim'

" color theme  and status line
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'powerline/fonts'

" auto close parenthesis etc.
Plugin 'tpope/vim-endwise'
" Plugin 'tpope/vim-surround' " to learn

call vundle#end()
filetype on
filetype plugin on
filetype indent on


"" GENERAL
let mapleader = ','
set lazyredraw " don't redraw while executing macros (for performance)
set encoding=utf8
set history=512 " number of commands to remember in history
set fileformats=unix,dos,mac " Use Unix as the standard file type
set wildmenu
set autoread    " automatically reads from file if modified outside of Vim
set hidden      " allow unsaved background

set noerrorbells " turn off bells
set novisualbell
set vb t_vb=

set nobackup " Turn backup off, since most stuff is in SVN, git et.c anyway...
set nowritebackup
set noswapfile

" behavior when switching buffer: use an open window if exist, followed by opened tab, etc.
try
  set switchbuf=useopen,usetab,newtab
  set showtabline=2
catch
endtry

set wildignore=*.o,*~,*.pyc " ignores compile files
if has("win16") || has("win32") " ignores version control files
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

"" MOVEMENT AND EDITING
set ignorecase " ignores case when searching
set smartcase  " don't ignore case when searching if search term has uppercase
set hlsearch   " highligh search terms
set incsearch  " search while typing
packadd! matchit
"set foldenable
"set foldmethod=syntax
"set foldlevel=128 " don't autofold

set backspace=eol,start,indent " allows backspacing through such characters
set whichwrap+=<,>,h,l,[,] " allows wrapping to next/prev lines when moving left and right

set tabstop=4
set softtabstop=4
set shiftwidth=4 "" 1 tab == 4 spaces
set expandtab " Use spaces instead of tabs
set smarttab " Be smart when using tabs ;)

set autoindent
set smartindent

" persistent undo
silent !mkdir ~/.vim/undo_history -p > /dev/null 2>&1
set undodir=~/.vim/undo_history
set undofile

"" VIEW
syntax enable
set background=dark
colorscheme solarized
se t_Co=16

set nonumber " hide the line number
set foldcolumn=1 " Add a bit extra margin to the left

set laststatus=2 " show airline
set showcmd " shows incomplete command in status line
set cursorline  " highlights current line

set scrolloff=7 " keeps 7 line above and below current line when scrolling vertically

set showmatch   " show matching parenthesis etc.
set matchtime=2 " ??

set nowrap " don't wrap lines
set textwidth=0 " disable auto line break

" changes cursor type according to modes
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

"" CONVENIENCE MAPPING
" Switch CWD to the directory of the open buffer
map <silent> <leader><cr> :noh<cr>
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" when line are wrapped, moves by displaye line instead of actual lines
map j gj
map k gk

"" AUTO COMMANDS
" automatically save views to keep folding
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview

" filetypes
autocmd BufRead,BufNewFile {Gemfile,Rakefile,*.rake,config.ru,*.rabl,*.rb} setlocal filetype=ruby tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
