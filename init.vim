" Yong Jie's init.vim for Neovim, 2020.08.29

" For no particular reason.
echo " ಠ_ಠ"


" -----------------------------------------------------------------------------
" Plugins
" -----------------------------------------------------------------------------
" Plugins are managed using vim-plug (available at
" https://github.com/junegunn/vim-plug).
"
" Follow the instructions at the link above to install vim-plug. As at the
" date of this document, the instructions are as follows:
" - For Neovim:
"   - Unix, Linux:
"     sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"
"   - Linux (Flatpak):
"     curl -fLo ~/.var/app/io.neovim.nvim/data/nvim/site/autoload/plug.vim \
"         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
"   - Windows (PowerShell):
"     iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
"         ni "$env:LOCALAPPDATA/nvim-data/site/autoload/plug.vim" -Force

" Plugins are listed between the plug#begin and plug#end function calls.
" - Run :PlugInstall to install the plugins. Note that certain plugins have other
"   prerequisites that must be satisfied before running :PlugInstall. For
"   example, 'juneguun/fzf' requires yarn to be installed on the system.
" - The directory in the plug#begin function is where the plugins will be
"   installed. This will very likely need to be changed for different
"   operating system.
call plug#begin('C:\Users\yongjie\AppData\Local\nvim\plugged')

" Enable running of Go commands directly from Vim (e.g., :GoRun, :GoBuild).
" After installing the plugin, run :GoInstallBinaries to install the Go binaries.
Plug 'fatih/vim-go'

" Add language server protocal support.
" Individual language needs to be set up separately. Please google for the
" instructions as appropriate.
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" Basic modern theme.
Plug 'joshdick/onedark.vim'

" Show a status line to clearly delineates vertical splits.
Plug 'rbong/vim-crystalline'

" Show number of matches and current match index for operations like *.
Plug 'google/vim-searchindex'

" Add fuzzy search for various actions within Vim (e.g., edit files, switching
" buffers).
" Prerequisites: yarn
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" For better workflow when using Git in certain cases. For example, :Git blame
" shows the output in two vertical splits, and the syntax highlight for the
" source file remains.
Plug 'tpope/vim-fugitive'

call plug#end()


" -----------------------------------------------------------------------------
" coc.nvim default settings
" -----------------------------------------------------------------------------
" Adapted from https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/.

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0


" -------------------------------------------------------------------------------------------------
" Colors and Theme
" -------------------------------------------------------------------------------------------------

" Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
" If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
" (see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    " For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  " For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  " Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

colorscheme onedark


" -----------------------------------------------------------------------------
" Quality-of-Life
" -----------------------------------------------------------------------------

" Wrap only at word boundaries.
set linebreak

" Ignore case when searching.
set ignorecase

" Don't ignore case when searching if search term contains uppercase
" character(s).
set smartcase

" When line are wrapped, moves by displaye line instead of actual lines.
map j gj
map k gk

" Don't redraw while executing macros (for performance).
set lazyredraw

" Ignore minimised javascript files for various wildcard operations.
set wildignore+=*.js.min

" Enable undo even after file is closed.
set undofile

" Highilght current line.
set cursorline

" Allow buffer containing modified file to be hidden.
set hidden


" -----------------------------------------------------------------------------
" Keymappings
" -----------------------------------------------------------------------------

" Use space as the leader key.
let mapleader=' '

" Switch to previous buffer.
nnoremap <Leader><Leader> :b#<CR>

" List buffers (for switching).
nnoremap <Leader>b :ls<CR>:b

" List history (for searching).
nnoremap <Leader>h :<C-f>?

" Allow quick ad-hoc normal mode mapping.
noremap <Leader>m :nnoremap<lt>Leader><lt>CR><Left><Left><Left><Left>

" Clear search highlight.
noremap <Leader><CR> :nohlsearch<CR>

" Toggle word wrap.
noremap <Leader>w :set wrap!<CR>

" Toggle relative number.
noremap <Leader>n :set relativenumber!<CR>

" Change to directory of current file.
noremap <leader>cd :cd %:p:h<cr>:pwd<cr>


" -----------------------------------------------------------------------------
" vim-crystalline settings
" -----------------------------------------------------------------------------

function! StatusLine(current, width)
  let l:s = ''

  if a:current
    let l:s .= crystalline#mode() . crystalline#right_mode_sep('')
  else
    let l:s .= '%#CrystallineInactive#'
  endif
  let l:s .= ' %f%h%w%m%r '
  if a:current
    let l:s .= crystalline#right_sep('', 'Fill') . ' %{fugitive#head()}'
  endif

  let l:s .= '%='
  if a:current
    let l:s .= crystalline#left_sep('', 'Fill') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
    let l:s .= crystalline#left_mode_sep('')
  endif
  if a:width > 80
    let l:s .= ' %{&ft}[%{&fenc!=#""?&fenc:&enc}][%{&ff}] %l/%L %c%V %P '
  else
    let l:s .= ' '
  endif

  return l:s
endfunction

function! TabLine()
  let l:vimlabel = has('nvim') ?  ' NVIM ' : ' VIM '
  return crystalline#bufferline(2, len(l:vimlabel), 1) . '%=%#CrystallineTab# ' . l:vimlabel
endfunction

let g:crystalline_enable_sep = 1
let g:crystalline_statusline_fn = 'StatusLine'
let g:crystalline_tabline_fn = 'TabLine'
let g:crystalline_theme = 'default'

" -----------------------------------------------------------------------------
" Mess
" -----------------------------------------------------------------------------
" Settings that haven't been put into any of the categories above.

set showtabline=1 " show tabline only when there are more than one tab
set guioptions-=e " When in GUI mode, use GUI to add tabs
set laststatus=2 " Always show status line
set cmdheight=1 " Use 1 line for command-line

let g:netrw_preview=1 " netrw (:Lexplore) previews (p) open to the right
let g:netrw_winsize=38 " netrw (:Lexplore) takes up 38% (golden ratio) of screen

set relativenumber " shows relative number; trying this out for now
set number " shows current line number when relative number mode is on

" Jump to last known position in a file after opening it.
autocmd BufReadPost *
\ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
\ |   exe "normal! g`\""
\ | endif

" Configure tabs to be 2 spaces wide, some these three options are always set
" together.
set tabstop=2 
set softtabstop=2
set shiftwidth=2

" Expand tab into spaces.
set expandtab 

" Pressing <Tab> key inserts blanks according to shiftwidth, tabstop and
" softtabstop.
set smarttab

" Automatically indents base on code (e.g., line after opening braces).
" autoindent and smartindent seems to be generally used together.
set autoindent 
set smartindent

" Disable automatic hard wrapping of lines.
set textwidth=0

" Display an angle bracket when wrapping lines.
set showbreak=>\

" Toggle "zen" mode by pressing <S-h>.
" Taken from
" https://unix.stackexchange.com/questions/140898/vim-hide-status-line-in-the-bottom.
let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction
nnoremap <S-h> :call ToggleHiddenAll()<CR>

