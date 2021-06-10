" Yong Jie's init.vim for Neovim, 2021.05.01

if !exists("g:os")
  if has("win64") || has("win32") || has("win16")
    let g:os = "Windows"
  else
    let g:os = substitute(system('uname'), '\n', '', '')
  endif
endif

" -----------------------------------------------------------------------------
" Machine-Specific Configurations
" -----------------------------------------------------------------------------

" yjPluginDir is where the plugins will be installed.
" E.g., "/home/yongjie/.local/share/nvim/plugged/"
let yjPluginDir='/Users/yongjie/.local/share/nvim/plugged/'

" yjBackupDir is where the backups will be stored.
" E.g., "/home/yongjie/.local/share/nvim/backup/"
let yjBackupDir=''

if g:os == "Windows"
  let yjPluginDir='C:\\Users\\yongjie\\AppData\\Local\\nvim\\plugged\\'
  let yjBackupDir='C:\\Users\\yongjie\\AppData\\Local\\nvim\\backup\\'
elseif g:os == "Linux"
  let yjPluginDir='/home/yongjie/.local/share/nvim/plugged/'
  let yjBackupDir='/home/yongjie/.local/share/nvim/backup/'
elseif g:os == "Darwin"
  let yjPluginDir=fnamemodify('~', ':p') . '.local/share/nvim/plugged/'
  let yjBackupDir=fnamemodify('~', ':p') . '.local/share/nvim/backup/'
endif

" -----------------------------------------------------------------------------
" init.vim
" -----------------------------------------------------------------------------

" For no particular reason.
" echo " ಠ_ಠ"
nnoremap <space>( :echo " ಠ_ಠ"<cr>

" Use space as the leader key. Putting this at the top of file so it occurs
" before any keymappings that uses <leader>.
let mapleader=' '


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
call plug#begin(yjPluginDir)

" Enable running of Go commands directly from Vim (e.g., :GoRun, :GoBuild).
" After installing the plugin, run :GoInstallBinaries to install the Go binaries.
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_gopls_enabled = 1 " Disable gopls because we are using Neovim's builtin LSP / coc.nvim.
let g:go_fmt_experimental = 1 " Fixes issues where folds are reset on saving.

" Add language server protocal support.
" Individual language needs to be set up separately. Please google for the
" instructions as appropriate.
Plug 'neoclide/coc.nvim', { 'do': 'yarn install --frozen-lockfile' }

" General fuzzy finder with preview.
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim' " Dependency of telescope.nvim

" Use FZF as telescope.nvim's fuzzy finder.
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Directory-based project management using telescope.nvim.
Plug 'nvim-telescope/telescope-project.nvim'

Plug 'neovim/nvim-lspconfig'

" nvim-cmp for auto-completion
" From https://github.com/hrsh7th/nvim-cmp/tree/1001683bee3a52a7b7e07ba9d391472961739c7b#recommended-configuration
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" For luasnip users.
" Plug 'L3MON4D3/LuaSnip'
" Plug 'saadparwaiz1/cmp_luasnip'

" For ultisnips users.
" Plug 'SirVer/ultisnips'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" For snippy users.
" Plug 'dcampos/nvim-snippy'
" Plug 'dcampos/cmp-snippy'

set completeopt=menu,menuone,noselect

" End from https://github.com/hrsh7th/nvim-cmp/tree/1001683bee3a52a7b7e07ba9d391472961739c7b#recommended-configuration

" Basic modern theme.
Plug 'joshdick/onedark.vim'

Plug 'NovaDev94/lightline-onedark'

" IntelliJ's default dark theme (Darcula), so people think I'm using IntelliJ.
" TODO: Use lightline with darcula theme as recommended by the "doumns/darcula"
" author: https://github.com/doums/darcula
Plug 'doums/darcula'

" Use a mode line that matches the Darcula theme just above.
Plug 'itchyny/lightline.vim'

" Show number of matches and current match index for operations like *.
Plug 'google/vim-searchindex'

" Add fuzzy search for various actions within Vim (e.g., edit files, switching
" buffers).
" Prerequisites: yarn
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" For "zen" mode
Plug 'junegunn/goyo.vim'
nnoremap <silent> <expr> <Leader>1 empty(get(t:, 'goyo_dim', '')) ? ':Goyo 62%<CR>' : ':Goyo!<CR>'

" Allow opening some of CocList in fzf
Plug 'antoinemadec/coc-fzf' 

" For better workflow when using Git in certain cases. For example, :Git blame
" shows the output in two vertical splits, and the syntax highlight for the
" source file remains.
Plug 'tpope/vim-fugitive'
nnoremap <silent> <Leader>[ :Git<CR>
" An extension to vim-fugitive for better viewing of branches (something like
" git log --pretty=one-line --graph).
Plug 'rbong/vim-flog'
let g:flog_permanent_default_arguments = { 'date': 'short' }

" Add to the GBrowse command from vim-fugitive ability to open GitLab links.
Plug 'shumphrey/fugitive-gitlab.vim'
" For managing Git branches with FZF from within Vim.
Plug 'stsewd/fzf-checkout.vim'

" For easy toggling of comments (e.g., with keybinding gcc)
Plug 'tpope/vim-commentary'

" For easy manipulation of quotes / brackes (e.g., with ysiw')
Plug 'tpope/vim-surround'

" For sensible bracket-related key mappings (e.g., [a ]a to move around
" argslist, [q ]q to move around quickfix list)
Plug 'tpope/vim-unimpaired'

" For showing changed lines based on git
Plug 'airblade/vim-gitgutter'
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" For typescript development, based on excellent article at
" https://thoughtbot.com/blog/modern-typescript-and-react-development-in-vim.
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'

" For Javascript syntax highlighting (reccommended by vim-jsx-pretty)
Plug 'yuezk/vim-js'
" For jsx indentation
Plug 'maxmellon/vim-jsx-pretty'

" For auto-closing of parens and related features
Plug 'jiangmiao/auto-pairs'
autocmd FileType TelescopePrompt     let b:autopairs_enabled=0

Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" For exploring tree-sitter
Plug 'nvim-treesitter/playground'

" Provides context in longer functions by keeping the signature lines visible.
" Plug 'romgrk/nvim-treesitter-context'

Plug 'tpope/vim-rhubarb' " GitHub extension for fugitive.vim
" Modifies GBrowse command added by tpope/vim-fugitive to open bitbucket links
Plug 'tommcdo/vim-fubitive'
" For typescript development, based on excellent article at
" https://thoughtbot.com/blog/modern-typescript-and-react-development-in-vim.
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'
" For using neovim to edit all textareas in browser.
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

" For setting persistent highlight on different words. Similar to
" M-x highlight-regexp on Emacs. 
Plug 'inkarkat/vim-mark'
Plug 'inkarkat/vim-ingo-library' " dependency of vim-mark
let g:mw_no_mappings=1
nnoremap <leader>m :Mark =expand('<cword>')<cr><cr>
nnoremap <leader>M :MarkClear<cr>
call plug#end()


" -------------------------------------------------------------------------------------------------
" Telescope
" -------------------------------------------------------------------------------------------------

nnoremap <leader>tb <cmd>lua require('telescope.builtin').builtin()<cr>

" nnoremap <leader>ff <cmd>lua require('telescope.builtin').oldfiles()<cr>
" nnoremap <leader>z <cmd>lua require('telescope.builtin').find_files()<cr>
" nnoremap <leader>g <cmd>lua require('telescope.builtin').git_files()<cr>
" nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap // <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>
" nnoremap ?? <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>h <cmd>lua require('telescope.builtin').command_history()<cr>

" TODO: Move the lsp keymappings below to init.lua, and only set them
" when lsp attaches (and only as buffer-local keymaps).
"
" TODO: Alternatively, use conditional mappings. E.g.,
"     CocHasProvider('rename') ? <use coc.nvim> : use nvim-lsp
"
" nnoremap gr <cmd>lua require('telescope.builtin').lsp_references()<cr>
" nnoremap gd <cmd>lua require('telescope.builtin').lsp_definitions()<cr>
" nnoremap gy <cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>
" nnoremap gi <cmd>lua require('telescope.builtin').lsp_implementations()<cr>
" nnoremap <leader>ac <cmd>lua require('telescope.builtin').lsp_code_actions()<cr>
" nnoremap <space>o <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
" nnoremap <space>O <cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>

nnoremap <space>p <cmd>lua require('telescope').extensions.project.project{}<cr>


" -------------------------------------------------------------------------------------------------
" Additional coc extensions
" -------------------------------------------------------------------------------------------------

let g:coc_global_extensions = [ 'coc-explorer', 'coc-tsserver', 'coc-go', 'coc-java', 'coc-json' ]


" -----------------------------------------------------------------------------
" coc.nvim default settings
" -----------------------------------------------------------------------------
" Adapted from https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/.

" Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')
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
" Remove the "-- INSERT --" text in the command area because the status line
" already shows this information.
set noshowmode

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

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[d` and `]d` to navigate diagnostics (e.g., errors)
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Modify coc.nvim's four commands above to use FZF using antoinemadec/coc-fzf,
" and configuring the FZF to be fullscreen
let g:coc_fzf_preview_fullscreen = 1
let g:coc_fzf_preview = 'up:77%'
let g:coc_fzf_opts = ['--layout=reverse']

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Show list of coc lists
nnoremap <silent> <leader>cl  :<C-u>CocFzfList<cr>

" Show all diagnostics
"nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
"nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocFzfList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocFzfList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocFzfList symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
" nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Show code actions for current buffer
nmap <leader>ac <Plug>(coc-codeaction)
" Show code actions for current line
nmap <leader>a. <Plug>(coc-codeaction-line)
" Show code actions for current selection
vmap <leader>a <Plug>(coc-codeaction-selected)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" disable vim-go :GoDef short-cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0

" disable vim-go :GoDoc short-cut (K)
" this is handled by the custom show_documentation() function below, which
" uses the LanguageClient [LC]
let g:go_doc_keywordprg_enabled = 0

" configure vim-go to use goimports (instead of gofmt) to format Go files on
" save
let g:go_fmt_command = "goimports"

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
" colorscheme darcula

" Link the CocHighlightText highlight group to the built-in DiffAdd highlight
" group. CocHighlightText group is used by coc.nvim for, among other things,
" highlight occurrences of symbol under cursor. See :help coc-highlight for
" more details.
highlight link CocHighlightText  DiffAdd


" -----------------------------------------------------------------------------
" Quality-of-Life
" -----------------------------------------------------------------------------

" Expand folds by default
set foldlevel=99

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

" Enable undo even after file is closed.
set undofile

" Highilght current line.
highlight CursorLine cterm=NONE guifg=NONE
set cursorline

" Allow buffer containing modified file to be hidden.
set hidden


" -----------------------------------------------------------------------------
" Keymappings
" -----------------------------------------------------------------------------

" Copy file path to clipboard
nnoremap <silent> <leader>yf :let @* = expand("%:p")<cr>

" Open file browser
nnoremap <silent> <space>e  :<C-u>CocCommand explorer<cr>

" Switch to previous buffer.
nnoremap <silent> <Leader><Leader> :b#<CR>

" List buffers (for switching).
"nnoremap <Leader>b :ls<CR>:b
" Start fuzzy search for opened buffers, requires vim-fzf plugin.
" nnoremap <silent> <Leader>b :Buffers!<CR>

" List history (for searching).
"nnoremap <Leader>h :<C-f>?
" Start fuzzy search for command history, requires vim-fzf plugin.
" nnoremap <silent> <Leader>h :History!<CR>

" Allow quick ad-hoc normal mode mapping.
" noremap <Leader>m :nnoremap<lt>Leader><lt>CR><Left><Left><Left><Left>

" Clear search highlight.
noremap <silent> <Leader><CR> :nohlsearch<CR>

" Toggle word wrap.
noremap <silent> <Leader>w :set wrap!<CR>

" Toggle relative number.
noremap <silent> <Leader>n :set relativenumber!<CR>

" Change to directory of current file.
noremap <silent> <leader>cd :cd %:p:h<cr>:pwd<cr>

" Start fuzzy search for files, requires vim-fzf plugin.
nnoremap <silent> <Leader>z :Files!<CR>

" Start fuzzy search for files not excluded by .gitignore, requires vim-fzf plugin.
nnoremap <silent> <Leader>g :GFiles!<CR>

" Start fuzzy search for recent files.
nnoremap <silent> <Leader>ff :History!<CR>

" Start fuzzy search for buffers.
" nnoremap <silent> <Leader>b :Buffers!<CR>

" Start fuzzy search lines in the current buffer, requires vim-fzf plugin.
" nnoremap <silent> // :BLines!<CR>

" Start fuzzy search for lines in all files, requires vim-fzf plugin.
nnoremap <silent> ?? :Rg!<CR>

" Start fuzzy search for lines in all files with words under cursor, requires vim-fzf plugin.
nnoremap <silent> <Leader>* :Rg! \b<c-r><c-w>\b<CR>

" Create folds by syntax.
nnoremap <silent> <Leader>fs :set foldmethod=syntax<CR>

" Create folds by indent.
nnoremap <silent> <Leader>fi :set foldmethod=indent<CR>

" Open splits to the right (if horizontal) and to below (if vertical).
set splitright
set splitbelow


" -------------------------------------------------------------------------------------------------
" fzf.vim settings
" -------------------------------------------------------------------------------------------------
" Open preview window to the top.
let g:fzf_preview_window = 'up:77%'


" -----------------------------------------------------------------------------
" lightline.vim settings
" -----------------------------------------------------------------------------

function! CocCurrentFunction()
  return get(b:,'coc_current_function','')
endfunction

" To switch back to darcula, change the colorscheme config back to the
" following:
     " \ 'colorscheme': 'darculaOriginal',
let g:lightline = {
     \ 'colorscheme': 'onedark',
     \ 'active': {
       \ 'left': [ [ 'mode', 'paste' ],
                 \ [ 'gitBranch', 'readonly', 'filename', 'modified' ],
                 \ [ 'currentFunction' ]],
       \ 'right': [ [ 'lineinfo' ], [ 'cocStatus' ] ],
     \ },
     \ 'component_function': {
       \ 'gitBranch': 'FugitiveHead',
       \ 'currentFunction': 'CocCurrentFunction',
       \ 'cocStatus': 'coc#status'
     \ },
     \ 'mode_map': {
       \ 'n' : 'N',
       \ 'i' : 'I',
       \ 'R' : 'R',
       \ 'v' : 'V',
       \ 'V' : 'VL',
       \ "\<C-v>": 'VB',
       \ 'c' : 'C',
       \ 's' : 'S',
       \ 'S' : 'SL',
       \ "\<C-s>": 'SB',
       \ 't': 'T'
     \ },
   \ }


" -----------------------------------------------------------------------------
" Mess
" -----------------------------------------------------------------------------
" Settings that haven't been put into any of the categories above.

" Configure font size for firenvim
function! OnUIEnter(event)
  let l:ui = nvim_get_chan_info(a:event.chan)
  if has_key(l:ui, 'client') && has_key(l:ui.client, 'name')
    if l:ui.client.name ==# 'Firenvim'
      set guifont=Iosevka:h20
    endif
  endif
endfunction
autocmd UIEnter * call OnUIEnter(deepcopy(v:event))

" Enable syntax highlight and code folding using nvim_treesitter.
nnoremap <silent> <Leader>t :TSEnable highlight<CR>:set foldmethod=expr \| :set foldexpr=nvim_treesitter#foldexpr()<CR>:e<CR>

" Enable history for fzf
let g:fzf_history_dir = '~/.local/share/fzf-history'

" Enable mouse (e.g., resizing splits).
set mouse=a

" Ignore minimised javascript files for various wildcard operations.
set wildignore+=*.js.min

" Remave node_modules folder from wildcard (used in npm projects).
set wildignore+=**/node_modules/**

" Remave vendor folder from wildcard (used in Go projects).
set wildignore+=**/vendor/**

" Remave target folder from wildcard (used in Maven projects).
set wildignore+=**/target/**

set showtabline=1 " show tabline only when there are more than one tab
set guioptions-=e " When in GUI mode, use GUI to add tabs
set laststatus=2 " Always show status line
set cmdheight=1 " Use 1 line for command-line

let g:netrw_preview=1 " netrw (:Lexplore) previews (p) open to the right
let g:netrw_winsize=38 " netrw (:Lexplore) takes up 38% (golden ratio) of screen

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

" Use '↪ ' to indicate soft-wrap
set showbreak=↪\ 

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
nnoremap <silent> <S-h> :call ToggleHiddenAll()<CR>


" Backups
set backup
set writebackup
call mkdir(yjBackupDir, "p", 0700)
" See :help :let-& for details on the syntax below
let &backupdir = yjBackupDir . '/'

if exists('+termguicolors') && ($TERM == "st-256color" || $TERM == "xterm-256color" || $TERM == "tmux-256color")
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

" -------------------------------------------------------- experimental --- {{{

" FZF plugin extension guide:
" 1. Find most similar existing command.
"    - E.g.: the :Buffers command
" 2. Find where the command is defined.
"    - E.g., https://github.com/junegunn/fzf.vim/blob/66cb8b826477671fba81c2db5fbb080c7b89f955/plugin/fzf.vim#L51
" 3. Pass in a dict containing or "sink", "sink*" to handle the response from
"    fzf.
"    - E.g.: { "sink*": s:myCustomFunction }
"    - Note: If a dict is already being passed in, add the "sink" / "sink*" key
"      to the existing dict.
"    - Note: the first line returned by fzf indicates how it was terminated,
"      empty string "" means the user pressed <Enter>, otherwise, it will be
"      strings like "ctrl-x", "ctrl-v", etc.
"
"      The additional keys must be set up in the initial command used to start
"      fzf, via the "--expect" command-line argument.
" 4. Pass in a dict containing "options" for other options to be passed to fzf
"    binary.
"    - Note: If a dict is already being passed in, add the "options" key
"      to the existing dict.
" 5. General Notes:
"    - When debugging, it may be possible to print out the intermediate results
"      of various wrapping functions.
"      - E.g.: echom fzf#wrap('ls')
"
" TODO: Modify a find referencees command to populate the quickfix list using
"       'ctrl-q'.
"       - For examples, refer to `s:fill_quickfix()` and how it is used, at
"       https://github.com/junegunn/fzf.vim/blob/66cb8b826477671fba81c2db5fbb080c7b89f955/autoload/fzf/vim.vim#L333

" An action can be a reference to a function that processes selected lines
function! s:delete_buffers(lines)
  " echom '[*] s:delete_buffers'
  let bufIndices = []
  for line in a:lines[1:]
    " echom '[*] line: ' . line
    let chunks = split(line, "\t", 1)
    for chunk in chunks
      " echom '[*] chuck: ' . chunk
      let bn = matchstr(chunk, '\[\zs[0-9]\{-}\ze\]') " e.g., matchs the "12" in "[12]"
      if !empty(bn)
        call add(bufIndices, bn)
      endif
    endfor
  endfor
  for bufIndex in bufIndices
    execute bufIndex . 'bd'
  endfor
endfunction

let s:myBuffersActions = {
  \ 'alt-enter' : function('s:delete_buffers'),
  \ 'ctrl-t'    : 'tab split',
  \ 'ctrl-x'    : 'split',
  \ 'ctrl-v'    : 'vsplit' }
let s:myBuffersExpect = ' --expect='.join(keys(s:myBuffersActions), ',')

let s:TYPE = {
      \ 'dict'    : type({}),
      \ 'list'    : type([]),
      \ 'funcref' : type(function('call')),
      \ 'string'  : type(''),
      \ }

" First item in `a:lines` is a string indicating how fzf was terminated: an
" empty string '' means fzf was terminated by pressing <Enter>; otherwise, it
" will be a string like 'ctrl-x', 'ctrl-v', etc.
"
" Adapted from https://github.com/junegunn/fzf.vim/blob/66cb8b826477671fba81c2db5fbb080c7b89f955/autoload/fzf/vim.vim#L668
function! s:bufopen(lines)
  " echom '[*] s:bufopen'
  echom a:lines
  if len(a:lines) < 2
    return
  endif
  let b = matchstr(a:lines[1], '\[\zs[0-9]*\ze\]')
  if empty(a:lines[0]) && get(g:, 'fzf_buffers_jump')
    let [t, w] = s:find_open_window(b)
    if t
      call s:jump(t, w)
      return
    endif
  endif
  let Cmd = get(s:myBuffersActions, a:lines[0], '')
  if type(Cmd) == s:TYPE.string
    " if Cmd is string, it must be "split", "vsplit", or "tab split"; we
    " execute Cmd first, before changing buffer.
    execute 'silent' Cmd
    execute 'buffer' b
  elseif type(Cmd) == s:TYPE.funcref
    " if Cmd is a funcref, we only call the funcref, but don't change buffer.
    call Cmd(a:lines)
  endif
endfunction

" Start fuzzy search of existing buffers, press <Enter> to switch, or press
" <Tab> to select multiple and press <Alt+Enter> to close multiple.
command! -bar -bang -nargs=? -complete=buffer MyBuffers
      \ call fzf#vim#buffers(<q-args>, fzf#vim#with_preview(
      \     { "placeholder": "{1}",
      \       "sink*": function("s:bufopen"),
      \       "options": "--multi".s:myBuffersExpect}), <bang>0)
  
nnoremap <silent> <Leader>b :MyBuffers!<CR>
" -------------------------------------------------------- experimental --- }}}

lua require('init')

" vim:fdm=marker
