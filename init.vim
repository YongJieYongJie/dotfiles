"" Yong Jie's init.vim for Neovim

"" Before
"
" For configurations that must come before other configurations (e.g. leader
" key)

" For no particular reason.
nnoremap <space>( :echo " ಠ_ಠ"<cr>

" Use space as the leader key. Putting this at the top of file so it occurs
" before any keymappings that uses <leader>.
let mapleader=' '

""" Machine-Specific Configurations

if !exists("g:os")
  if has("win64") || has("win32") || has("win16")
    let g:os = "Windows"
  else
    let g:os = substitute(system('uname'), '\n', '', '')
  endif
endif

" yjPluginDir is where the plugins will be installed.
" E.g., "/home/yongjie/.local/share/nvim/plugged/"
let yjPluginDir=''

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

"" Plugins

""" Plugins: Installation
"
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

Plug 'fatih/vim-go' ", { 'do': ':GoUpdateBinaries' }

Plug 'neoclide/coc.nvim', { 'branch': 'release' }

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim' " Dependency of telescope.nvim

" Use FZF as telescope.nvim's fuzzy finder.
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Directory-based project management using telescope.nvim.
Plug 'nvim-telescope/telescope-project.nvim'

Plug 'neovim/nvim-lspconfig'

" " nvim-cmp for auto-completion
" " From https://github.com/hrsh7th/nvim-cmp/tree/1001683bee3a52a7b7e07ba9d391472961739c7b#recommended-configuration
" Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-buffer'
" Plug 'hrsh7th/cmp-path'
" Plug 'hrsh7th/cmp-cmdline'
" Plug 'hrsh7th/nvim-cmp'

" " For vsnip users.
" Plug 'hrsh7th/cmp-vsnip'
" Plug 'hrsh7th/vim-vsnip'

" For luasnip users.
" Plug 'L3MON4D3/LuaSnip'
" Plug 'saadparwaiz1/cmp_luasnip'

" For ultisnips users.
" Plug 'SirVer/ultisnips'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" For snippy users.
" Plug 'dcampos/nvim-snippy'
" Plug 'dcampos/cmp-snippy'

" set completeopt=menu,menuone,noselect

" End from https://github.com/hrsh7th/nvim-cmp/tree/1001683bee3a52a7b7e07ba9d391472961739c7b#recommended-configuration

" Basic modern theme.
Plug 'joshdick/onedark.vim'

Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

Plug 'NovaDev94/lightline-onedark'

" IntelliJ's default dark theme (Darcula), so people think I'm using IntelliJ.
" TODO: Use lightline with darcula theme as recommended by the "doumns/darcula"
" author: https://github.com/doums/darcula
Plug 'doums/darcula'

" Use a mode line that matches the Darcula theme just above.
Plug 'itchyny/lightline.vim'

" Show number of matches and current match index for operations like *.
Plug 'google/vim-searchindex'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Allow opening some of CocList in fzf
Plug 'antoinemadec/coc-fzf' 

" Add preview to more fzf commands
Plug 'chengzeyi/fzf-preview.vim'

Plug 'junegunn/goyo.vim'

" For better workflow when using Git in certain cases. For example, :Git blame
" shows the output in two vertical splits, and the syntax highlight for the
" source file remains.
Plug 'tpope/vim-fugitive'

" An extension to vim-fugitive for better viewing of branches (something like
" git log --pretty=one-line --graph).
Plug 'rbong/vim-flog'

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

Plug 'airblade/vim-rooter'

" For showing changed lines based on git
Plug 'airblade/vim-gitgutter'

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

Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

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

Plug 'nvim-orgmode/orgmode'

Plug 'tpope/vim-repeat'
" Plug 'chrisbra/NrrwRgn'

" Plug 'https://git.sr.ht/~whynothugo/lsp_lines.nvim'
Plug 'YongJieYongJie/lsp_lines.nvim', { 'branch': 'feature--coc-current-line-only' }

" For general linting
Plug 'dense-analysis/ale'

" For running tests
Plug 'vim-test/vim-test'

" For lf integration
Plug 'ptzz/lf.vim'
Plug 'voldikss/vim-floaterm' " dependency of lf.vim

Plug 'chimay/organ'

Plug 'aklt/plantuml-syntax'
Plug 'weirongxu/plantuml-previewer.vim'
Plug 'tyru/open-browser.vim'

Plug 'NeogitOrg/neogit'
Plug 'nvim-lua/plenary.nvim'         " dependency of neogit
Plug 'nvim-telescope/telescope.nvim' " dependency of neogit
Plug 'sindrets/diffview.nvim'        " dependency of neogit
Plug 'ibhagwan/fzf-lua'              " dependency of neogit
Plug 'nvim-tree/nvim-web-devicons'   " dependency of neogit

call plug#end()

""" Plugins: vim-go
"
" Enable running of Go commands directly from Vim (e.g., :GoRun, :GoBuild).
" After installing the plugin, run :GoInstallBinaries to install the Go binaries.

" Disable gopls because we are using Neovim's builtin LSP / coc.nvim.
let g:go_gopls_enabled = 0

" Fixes issues where folds are reset on saving.
let g:go_fmt_experimental = 1

" disable vim-go :GoDef short-cut (gd) as this is handled by LSP
let g:go_def_mapping_enabled = 0

" disable vim-go :GoDoc short-cut (K) as this is handled by coc.nvim
let g:go_doc_keywordprg_enabled = 0

" configure vim-go to use goimports (instead of gofmt) to format Go files on
" save
let g:go_fmt_command = "goimports"

""" Plugins: coc.nvim
"
" Add language server protocal support.
" Individual language needs to be set up separately. Please google for the
" instructions as appropriate.

"""" Plugins: coc.nvim: Extensions Installation
"
" Additional extension that coc.nvim can install for us.
let g:coc_global_extensions = [ 
      \ 'coc-json',
      \ 'coc-lists',
      \ 'coc-explorer',
      \ 'coc-git',
      \ 'coc-vimlsp',
      \ 'coc-sumneko-lua',
      \ 'coc-tsserver',
      \ 'coc-go',
      \ 'coc-java',
      \ 'coc-rust-analyzer',
      \ 'coc-pyright',
      \ ]

if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

"""" Plugins: coc.nvim: default settings
"
" Adapted from https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/.

" Fix issue where status line does not update when coc-related information changes
" https://github.com/neoclide/coc.nvim/issues/2993#issuecomment-1250717402
autocmd User CocStatusChange redrawstatus

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
" set signcolumns to auto by default
set signcolumn=auto

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" The line below doesn't seem to work. I.e., when selecting a function
" completion, it doesn't add the parenthesies.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

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

" Modify coc.nvim's four commands above to use FZF using antoinemadec/coc-fzf,
" and configuring the FZF to be fullscreen
let g:coc_fzf_preview_fullscreen = 1
let g:coc_fzf_preview = 'up:77%'
let g:coc_fzf_opts = ['--layout=reverse']

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>fd  <Plug>(coc-format)

" Show list of coc lists
nnoremap <silent> <leader>cl  :<C-u>CocFzfList<cr>

" Show all diagnostics
"nnoremap <silent> <leader>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
"nnoremap <silent> <leader>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <leader>cm  :<C-u>CocFzfList commands<cr>
" Find symbol of current document
nnoremap <silent> <leader>o  :<C-u>CocFzfList outline<cr>
" Search workspace symbols
nnoremap <silent> <leader>s  :<C-u>CocFzfList symbols<cr>
" Do default action for next item.
nnoremap <silent> <leader>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <leader>k  :<C-u>CocPrev<CR>
" Resume latest coc list
" nnoremap <silent> <leader>p  :<C-u>CocListResume<CR>

" Show code actions for current buffer
nmap <leader>ac <Plug>(coc-codeaction)
" Show code actions at cursor
nmap <leader>aa <Plug>(coc-codeaction-cursor)
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

"""" Plugins: coc.nvim: enable both default and FZF pickers

" Set up and keymappings to use coc built-in picker when using lowercase
" binding, and FZF when using uppercase binding.
"
" The way these group of bindings work is that coc will populate the
" g:coc_jump_locations variable with the list of target locations, and trigger
" the CocLocationsChange event.
"
" However, the coc-fzf plugin has an augroup CocFzfLocation that forcibly
" overrides all CocLocationsChange event to handle the locations with FZF.
" 
" We are working around this by using timer_start to schedule a function to
" clear the augroup set by coc-fzf plugin, and replace it with our augroup
" that handles CocLocationsChange with our custom function which decides which
" picker to use based on g:use_fzf variable.
"
" Note: It seems possible to instead manually populate g:coc_jump_locations
" using somthing like:
"   nmap <silent> gr :let g:coc_jump_locations=CocAction('references') \| :call coc_fzf#location#fzf_run()<cr>
"
" however, the output of CocAction('references') is subtly different from that
" populated when calling CocAction('jumpReferences'), and coc-fzf only works
" with the latter.

eval timer_start(1000, 'YJ_DisableCocFzfAugroup')
function! YJ_DisableCocFzfAugroup(id)
  let g:coc_enable_locationlist = 0
  autocmd! CocFzfLocation
  augroup YjCocFzfLocation
    autocmd! User CocLocationsChange nested call YJ_HandleCocLocationsChange()
  augroup END
endfunction

function! YJ_HandleCocLocationsChange()
  if g:use_fzf
    call coc_fzf#location#fzf_run()
  else
    CocList --auto-preview location
  endif
endfunction

nmap <silent> gR :let g:use_fzf=1 \| :call CocAction('jumpReferences')<cr>
nmap <silent> gr :let g:use_fzf=0 \| :call CocAction('jumpReferences')<cr>

nmap <silent> gD :let g:use_fzf=1 \| :call CocAction('jumpDefinition')<cr>
nmap <silent> gd :let g:use_fzf=0 \| :call CocAction('jumpDefinition')<cr>

nmap <silent> gY :let g:use_fzf=1 \| :call CocAction('jumpTypeDefinition')<cr>
nmap <silent> gy :let g:use_fzf=0 \| :call CocAction('jumpTypeDefinition')<cr>

nmap <silent> gI :let g:use_fzf=1 \| :call CocAction('jumpImplementation')<cr>
nmap <silent> gi :let g:use_fzf=0 \| :call CocAction('jumpImplementation')<cr>

""" Plugins: telescope.nvim
"
" General fuzzy finder with preview.

nnoremap <leader>tb <cmd>lua require('telescope.builtin').builtin({previewer=false})<cr>

" nnoremap <leader>ff <cmd>lua require('telescope.builtin').oldfiles()<cr>
" nnoremap <leader>z <cmd>lua require('telescope.builtin').find_files()<cr>
" nnoremap <leader>g <cmd>lua require('telescope.builtin').git_files()<cr>
" nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap // <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>
" nnoremap ?? <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap ?/ <cmd>lua require('telescope.builtin').grep_string()<cr>
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
" nnoremap <leader>o <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
" nnoremap <leader>O <cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>

nnoremap <leader>p <cmd>lua require('telescope').extensions.project.project{}<cr>

""" Plugins: fzf
"
" Add fuzzy search for various actions within Vim (e.g., edit files, switching
" buffers).
" Prerequisites: yarn

" Open preview window to the top.
let g:fzf_preview_window = ['up:77%', 'ctrl-/']

" Enable history for fzf
let g:fzf_history_dir = '~/.local/share/fzf-history'

"""" Plugins: fzf: maximize screen estate

autocmd! FileType fzf call YJ_BeforeFzf()
  \| autocmd BufLeave <buffer> call YJ_AfterFzf()

let s:prev_show_mode='showmode'
let s:prev_last_status=2
function! YJ_BeforeFzf()
  let s:prev_show_mode=&showmode
  let s:prev_last_status=&laststatus
  set laststatus=0
  set noshowmode
  set noruler
endfunction
function! YJ_AfterFzf()
  if s:prev_show_mode
    set showmode
  endif
  if s:prev_last_status
    set laststatus=2
  endif
  set ruler
endfunction

"""" Plugins: fzf: delete buffers using alt+enter

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
    try
      execute 'try | ' . bufIndex . 'bd' . '| catch | | endtry'
    catch
      " do nothing
    endtry
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

""" Plugins: goyo.vim
"
" Add "zen" mode

let g:goyo_height='100%'
nnoremap <silent> <expr> <Leader>1 empty(get(t:, 'goyo_dim', '')) ? ':Goyo 62%<CR>' : ':Goyo!<CR>'

" Returns the number of characters in the longest line in the current buffer.
function! YJ_LongestLineWidth()
  " Note: the plus two below is for the signcolumn.
  " Adapted from https://superuser.com/a/255438/1021469
  return max(map(range(1, line('$')), "col(["v:val, '$'])")) - 1 + 2
endfunction

" Returns the number of characters in the longest visible line in the current buffer.
function! YJ_LongestVisibleLineWidth()
  " Adapted from https://superuser.com/a/255438/1021469
  return max(map(range(line('w0'), line('w$')), "col([v:val, '$'])")) - 1
endfunction

" Returns the total number of lines in the current buffer.
function! YJ_NumLines()
  return line('$')
endfunction

" Centralize the current buffer (horizontally and vertically) and hides all
" other windows. Useful for making presentations.
nnoremap <silent> <expr> <Leader>! ':Goyo ' . YJ_LongestVisibleLineWidth() . 'x' . YJ_NumLines() . '<CR>'

""" Plugins: vim-fugitive

" nnoremap <silent> <Leader>[ :tabnew<CR>:Git<CR><C-w><C-o>
nnoremap <silent> <Leader>{ :Git<CR>
autocmd FileType gitcommit,git set foldmethod=syntax

""" Plugins: vim-flog

let g:flog_permanent_default_arguments = { 'date': 'short' }

""" Plugins: vim-rooter

let g:rooter_patterns = [
      \ '.git',
      \ '_darcs',
      \ '.hg',
      \ '.bzr',
      \ '.svn',
      \ 'package.json',
      \ 'Cargo.toml'
      \ ]

""" Plugins: vim-gitgutter

nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

""" Plugins: auto-pairs

autocmd FileType TelescopePrompt,org,NeogitStatus let b:autopairs_enabled=0

""" Plugins: vim-mark

let g:mw_no_mappings=1
nnoremap <silent> <leader>m :silent Mark =expand('<cword>')<cr><cr>
nnoremap <silent> <leader>M :silent MarkClear<cr>
xnoremap <silent> <leader>m y:silent Mark /"/<cr>

""" Plugins: lsp_lines.nvim

nnoremap <leader>ll :call CocAction('toggleExtension', 'lsp_lines')

""" Plugins: ale

let g:ale_linters = {'kotlin': ['ktlint']}
let g:ale_fixers = {'kotlin': ['ktlint']}
let g:ale_use_neovim_diagnostics_api = 0
let g:ale_virtualtext_cursor = 0

""" Plugins: vim-test

" Run tests in a neovim terminal
let test#strategy = "neovim"
" Keep terminal around even with pressing keys
let g:test#neovim#start_normal = 1

""" Plugins: lf.vim

let g:lf_width=1.0
let g:lf_height=1.0
let g:lf_map_keys = 0

""" Plugins: neogit

nnoremap <silent> <Leader>[ :Neogit<CR><C-w><C-o>

""" Plugins: lightline.vim

" Remove the "-- INSERT --" text in the command area because the status line
" already shows this information.
set noshowmode

function! CocCurrentFunction()
  return get(b:,'coc_current_function','')
endfunction

" To switch back to darcula, change the colorscheme config back to the
" following:
     " \ 'colorscheme': 'onedark',
     " \ 'colorscheme': 'darculaOriginal',
let g:lightline = {
     \ 'colorscheme': 'catppuccin',
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

""" Plugins: firenvim

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

""" Plugins: organ - improved navigation for markdown and org files
" Enable organ with :Organ

let g:organ_config = {}
let g:organ_config.speedkeys = 1
let g:organ_config.previous = '<M-p>'

"" Colors and Theme

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

" colorscheme onedark
" colorscheme darcula
colorscheme catppuccin-mocha

" Color tweak for darcula theme because the hover pop-up for error diagnostic
" doesn't have enough contrast.
highlight FgCocErrorFloatBgCocFloating ctermfg=1 ctermbg=238 guifg='LightRed' guibg=#46484a

" Link the CocHighlightText highlight group to the built-in DiffAdd highlight
" group. CocHighlightText group is used by coc.nvim for, among other things,
" highlight occurrences of symbol under cursor. See :help coc-highlight for
" more details.
highlight link CocHighlightText  DiffAdd

"" Quality-of-Life

" Navigate jump help file links using <Tab> and <S-Tab>
" Copied from https://github.com/joeytwiddle/rc_files/blob/master/.vim/ftplugin/help/navigate.vim
augroup YJ_Help
  autocmd!
  autocmd filetype help call YJ_HelpKeymaps()
augroup END

function! YJ_HelpKeymaps()
  nnoremap <silent> <buffer>   <Tab> /\('\zs\k\+'\\|[<Bar>]\zs\k\+[<Bar>]\)<CR>:set nohlsearch<CR>
  nnoremap <silent> <buffer> <S-Tab> ?\('\zs\k\+'\\|[<Bar>]\zs\k\+[<Bar>]\)<CR>:set nohlsearch<CR>
endfunction

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

" Hide netrw banner by default
let g:netrw_banner=0

""" Neovide / GUI

" Separate function for fixing Neovide copying and pasting. This
" function needs to be manually called when Neovide attaches to a
" Neovim server because when the server is launched,
" exist("g:neovide") is false, and the code further below will not be
" executed.
function! YJ_NeovideCopyPasteFix()
  map <D-v> "+p<CR>
  map! <D-v> <C-R>+
  tmap <D-v> <C-R>+
  vmap <D-c> "+y<CR>
endfunction

" Fixes copying and pasting with command key in macOS + Neovide
" Copied from https://github.com/neovide/neovide/issues/1263#issuecomment-1292801824
if exists("g:neovide")
  call YJ_NeovideCopyPasteFix()
endif

set guifont=Iosevka\ Nerd\ Font\ Mono:h17

" Increase font size when in GUI mode (e.g., in Neovide).
function! YJ_FontSizeIncrease()
  let curr_font = matchstr(&guifont, '\zs.\+\ze:h[0-9\+]')
  let curr_size = matchstr(&guifont, ':h\zs[0-9]\+\ze')
  let &guifont= curr_font . ':h' . (curr_size+1)
endfunction

" Decrease font size when in GUI mode (e.g., in Neovide).
function! YJ_FontSizeDecrease()
  let curr_font = matchstr(&guifont, '\zs.\+\ze:h[0-9\+]')
  let curr_size = matchstr(&guifont, ':h\zs[0-9]\+\ze')
  let &guifont= curr_font . ':h' . (curr_size-1)
endfunction

nnoremap <silent> <c-=> :call YJ_FontSizeIncrease()<CR>
nnoremap <silent> <c--> :call YJ_FontSizeDecrease()<CR>
" Make sure key combinations like <M-CR> works in Neovide. From
" https://github.com/neovide/neovide/discussions/1270#discussioncomment-5850851
let g:neovide_input_macos_alt_is_meta = v:true

"" Personal Functions

""" Personal Functions: Toggle maximized (like Tmux's zoom)

nnoremap <silent> <leader>z :call YJ_ToggleMaximized()<CR>

" Checks whether the current window is maximized by
"  1. storing the current height and width
"  2. maximizing the current window and recording the maximized height and width
"  3. undo-ing the maximizing
"  4. comparing the before and after height and width
"  
"  Credits: Inspired by reddit comment which mention the winrestcmd() builtin
"  function:
"  https://www.reddit.com/r/vim/comments/9e9bnh/comment/e5oix67/?utm_source=share&utm_medium=web2x&context=3
function! YJ_IsMaximized()
  let curr_width = winwidth(0)
  let curr_height = winheight(0)
  let yj_cmd_to_restore_win_sizes = winrestcmd()
  resize
  vertical resize
  let maximized_width = winwidth(0)
  let maximized_height = winheight(0)
  exec yj_cmd_to_restore_win_sizes
  return curr_width == maximized_width && curr_height == maximized_height
endfunction

" Toggle the maximized status of the current window. Works across tabs.
function! YJ_ToggleMaximized()
  if YJ_IsMaximized()
    if has_key(g:yj_cmd_to_restore_win_sizes, tabpagenr()-1)
      let cmd = remove(g:yj_cmd_to_restore_win_sizes, tabpagenr()-1)
      exec cmd
    else
      " If the restore command doesn't exst, we simply equalize all windows.
      call feedkeys("\<C-w>=")
    endif
  else
    let g:yj_cmd_to_restore_win_sizes[tabpagenr()-1] = winrestcmd()
    resize
    vertical resize
  endif
endfunction
let g:yj_cmd_to_restore_win_sizes = {}
""" Personal Functions: Toggle tabline and modeline

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
        set showtabline=0
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
        set showtabline=1
    endif
endfunction
nnoremap <silent> <S-h> :call ToggleHiddenAll()<CR>

""" Personal Functions: Folding

" Alternative foldtext implementation to display first line of folded text
" exactly as it would appear (i.e., same indentation) so it would be easy to
" see the first line of folded text within the context of the surrounding
" code.
"
" So instead of the default:
"   +--42 lines folded.........................................................
"
" we get something like:
"   const myTypescriptObject = {...};
"
" Might not work for languages like Python.
"
" Adapted from https://github.com/nvim-treesitter/nvim-treesitter/pull/390#issuecomment-709666989
function! YJ_EmacsLikeFoldText()
  let startLineText = getline(v:foldstart)
  let endLineText = trim(getline(v:foldend))
  let indentation = GetSpaces(foldlevel("."))
  let spaces = repeat(" ", 200)
  let str = indentation . startLineText . "..." . endLineText . spaces
  return str
endfunction
function! GetSpaces(foldLevel)
  if &expandtab == 1
    " Indenting with spaces
    let str = repeat(" ", a:foldLevel / (&shiftwidth + 1) - 1)
    return str
  elseif &expandtab == 0
    " Indenting with tabs
    return repeat(" ", indent(v:foldstart) - (indent(v:foldstart) / &shiftwidth))
  endif
endfunction

" Custom display for text when folding
set foldtext=YJ_EmacsLikeFoldText()

" Alternative foldexpr implementation for folding vimrc file by headings.
"
" Headings are defined by leading double quotes: heading 1 begins with two
" double quotes, heading 2 begins with three double quotes, etc.
function! YJ_VimrcFoldExpr()
  let currLine = getline(v:lnum)
  if '""' != currLine[0:1]
    return '='
  endif
  let leadingQuotes = substitute(currLine, '^\("\+\).*', "\\1", "") 
  let calculatedFoldLevel = len(leadingQuotes) - 1
  return ">" . calculatedFoldLevel
endfunction

" Generate fold text using only the starting line. For use with
" 'YJ_VimrcFoldExpr'
function! YJ_FoldTextStartLine()
  let startLineText = getline(v:foldstart)
  let indentation = GetSpaces(foldlevel("."))
  let spaces = repeat(" ", 200)
  let str = indentation . startLineText . "..." . spaces
  return str
endfunction

" Alternative foldexpr implementation for folding init.lua file by headings.
"
" Headings are defined by leading hyphens: heading 1 begins with three
" hyphens, heading 2 begins with four double quotes, etc.
function! YJ_InitLuaFoldExpr()
  let currLine = getline(v:lnum)
  if '---' != currLine[0:2]
    return '='
  endif
  let leadingQuotes = substitute(currLine, '^\(-\+\).*', "\\1", "") 
  let calculatedFoldLevel = len(leadingQuotes) - 2
  return ">" . calculatedFoldLevel
endfunction

"" Keymappings

" Copy file path to clipboard
nnoremap <silent> <leader>yf :let @* = expand("%:p")<cr>

" Open file browser
nnoremap <silent> <space>e  :<C-u>CocCommand explorer<cr>

" Expand file browser to current buffer
nmap <Leader>E <Cmd>call CocAction('runCommand', 'explorer.doAction', 'closest', ['reveal:0'], [['relative', 0, 'file']])<CR>

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

" Cycle among no line number, only line number, and relative line number
" modes.
function! YJ_CycleLineNumber()
  let isNumber = &number
  let isRelativeNumber = &relativenumber

  if isNumber && isRelativeNumber
    set nonumber
    set norelativenumber
    return
  endif

  if isNumber
    set relativenumber
    return
  endif

  set number
endfunction
noremap <silent> <Leader>n :call YJ_CycleLineNumber()<CR>

" Change to directory of current file.
noremap <silent> <leader>cd :cd %:p:h<cr>:pwd<cr>

" Start fuzzy search for files, requires vim-fzf plugin.
nnoremap <silent> <Leader>F :Files!<CR>

" Start fuzzy search for files not excluded by .gitignore, requires vim-fzf plugin.
nnoremap <silent> <Leader>g :GFiles!<CR>
nnoremap <silent> <Leader>G :GFiles!<CR> <c-r><c-w><c-f>bi\b<c-[>A\b<c-[><CR>

" Start fuzzy search for recent files.
nnoremap <silent> <Leader>ff :History!<CR>

" Start fuzzy search for all commands
nnoremap <silent> <Leader>cc :Commands!<CR>

" Start fuzzy search for buffers.
" nnoremap <silent> <Leader>b :Buffers!<CR>

" Start fuzzy search lines in the current buffer, requires vim-fzf plugin.
" nnoremap <silent> // :BLines!<CR>

" Start fuzzy search for lines in all files, requires vim-fzf plugin.
nnoremap <silent> ?? :Rg!<CR>

" Start fuzzy search for lines in all files with words under cursor, requires vim-fzf plugin.
" nnoremap <silent> <Leader>* :Rg! \b<c-r><c-w>\b<CR>
nnoremap <silent> <Leader>* :Rg! <c-r><c-w><c-f>bi\b<c-[>A\b<c-[><CR>

xnoremap <silent> <Leader>* y<c-[>:Rg! <c-r>"<CR>

" Start fuzzy search for lines in current file with words under cursor, requires vim-fzf plugin.
nnoremap <silent> <Leader>/ :BLines! <c-r><c-w><CR>

xnoremap <silent> <Leader>/ y<c-[>:BLines! '<c-r>"<CR>

" Create folds by syntax.
nnoremap <silent> <Leader>fs :set foldmethod=syntax<CR>

" Create folds by indent.
nnoremap <silent> <Leader>fi :set foldmethod=indent<CR>

" Use <c-[> to enter normal mode in terminal
tnoremap <expr> <c-[> (&filetype == "fzf") ? "<c-[>" : "<c-\><c-n>"

" Open splits to the right (if horizontal) and to below (if vertical).
set splitright
set splitbelow



"" Mess
"
" Settings that haven't been put into any of the categories above.

" Enable syntax highlight and code folding using nvim_treesitter.
nnoremap <silent> <Leader>ts :TSEnable highlight<CR>:set foldmethod=expr \| :set foldexpr=nvim_treesitter#foldexpr()<CR>:e<CR>

" Enable mouse (e.g., resizing splits).
set mouse=a

" Ignore minimised javascript files for various wildcard operations.
set wildignore+=*.js.min

" Remove node_modules folder from wildcard (used in npm projects).
set wildignore+=**/node_modules/**

" Remove vendor folder from wildcard (used in Go projects).
set wildignore+=**/vendor/**

" Remove target folder from wildcard (used in Maven projects).
set wildignore+=**/target/**

" Ignore case when auto-completing in command mode (e.g., when pressing
" <TAB>)
set wildignorecase

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

"" Experimental

" Show syntax highlighting groups for word under cursor
" From: https://stackoverflow.com/a/9464929
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" From: https://stackoverflow.com/a/37040415
function! SynGroup()
  let l:s = synID(line('.'), col('.'), 1)
  echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun

" Replaces escaped line breaks and tabs with actual line breaks and tabs
nnoremap <leader>N :%s/\\n/\r/g:%s/\\t/\t/g

let &grepprg = 'rg --vimgrep'
let &grepformat = '%f:%l:%c:%m,%f:%l:%m'

" Remember folds
" Copied from https://stackoverflow.com/a/54739345/5821101
" augroup remember_folds
"   autocmd!
"   autocmd BufWinLeave * mkview
"   autocmd BufWinEnter * silent! loadview
" augroup END

" Shift+Enter in normal mode to insert semi-colon at the end of line without
" changing cursor position.
nnoremap ,<CR> mzA;g`z

" Returns the root directory or an empty string if no root directory found.
function! YJNearestGit()
  let dir = YJCurrentDir()

  " breadth-first search
  while 1
    for pattern in ['.git']
    " for pattern in g:rooter_patterns
      if pattern[0] == '!'
        let [p, exclude] = [pattern[1:], 1]
      else
        let [p, exclude] = [pattern, 0]
      endif
      if s:match(dir, p)
        if exclude
          break
        else
          return dir
        endif
      endif
    endfor

    let [current, dir] = [dir, YJParentDir(dir)]
    if current == dir | break | endif
  endwhile

  return ''
endfunction

" Returns full path of directory of current file name (which may be a directory).
function! YJCurrentDir()
  let fn = expand('%:p', 1)
  if fn =~ 'NERD_tree_\d\+$' | let fn = b:NERDTree.root.path.str().'/' | endif
  if empty(fn) | return getcwd() | endif  " opening vim without a file
  " if g:rooter_resolve_links | let fn = resolve(fn) | endif
  return fnamemodify(fn, ':h')
endfunction

" Returns full path of dir's parent directory.
function! YJParentDir(dir)
  return fnamemodify(a:dir, ':h')
endfunction

function s:match(dir, pattern)
  if a:pattern[0] == '='
    return s:is(a:dir, a:pattern[1:])
  elseif a:pattern[0] == '^'
    return s:sub(a:dir, a:pattern[1:])
  elseif a:pattern[0] == '>'
    return s:child(a:dir, a:pattern[1:])
  else
    return s:has(a:dir, a:pattern)
  endif
endfunction

" Returns true if dir is identifier, false otherwise.
"
" dir        - full path to a directory
" identifier - a directory name
function! s:is(dir, identifier)
  let identifier = substitute(a:identifier, '/$', '', '')
  return fnamemodify(a:dir, ':t') ==# identifier
endfunction

" Returns true if dir contains identifier, false otherwise.
"
" dir        - full path to a directory
" identifier - a file name or a directory name; may be a glob
function! s:has(dir, identifier)
  " We do not want a:dir to be treated as a glob so escape any wildcards.
  " If this approach is problematic (e.g. on Windows), an alternative
  " might be to change directory to a:dir, call globpath() with just
  " a:identifier, then restore the working directory.
  return !empty(globpath(escape(a:dir, '?*[]'), a:identifier, 1))
endfunction

" Returns true if identifier is an ancestor of dir,
" i.e. dir is a subdirectory (no matter how many levels) of identifier;
" false otherwise.
"
" dir        - full path to a directory
" identifier - a directory name
function! s:sub(dir, identifier)
  let path = s:parent(a:dir)
  while 1
    if fnamemodify(path, ':t') ==# a:identifier | return 1 | endif
    let [current, path] = [path, s:parent(path)]
    if current == path | break | endif
  endwhile
  return 0
endfunction

" Return true if identifier is a direct ancestor (parent) of dir,
" i.e. dir is a direct subdirectory (child) of identifier; false otherwise
"
" dir        - full path to a directory
" identifier - a directory name
function! s:child(dir, identifier)
  let path = s:parent(a:dir)
  return fnamemodify(path, ':t') ==# a:identifier
endfunction

augroup vimrc
  autocmd!
  autocmd FileType vim set modelineexpr
augroup END

augroup initlua
  autocmd!
  autocmd BufReadPost init.lua,coc-settings.json set modelineexpr
augroup END

"" After
"
" For configurations that must come after other configurations

lua require('init')

" vim: foldmethod=expr foldexpr=YJ_VimrcFoldExpr() foldtext=YJ_FoldTextStartLine()
