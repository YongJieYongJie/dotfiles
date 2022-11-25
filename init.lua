-------------------------------------------------------------------- orgmode ---{{{

-- Load custom tree-sitter grammar for org filetype
require('orgmode').setup_ts_grammar()

-- Tree-sitter configuration
require'nvim-treesitter.configs'.setup {
  -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = {'org'}, -- Required for spellcheck, some LaTex highlights and code block highlights that do not have ts grammar
  },
  ensure_installed = {'org'}, -- Or run :TSUpdate org
}

require('orgmode').setup({
  org_agenda_files = {'~/coding-playground/java/aeron/README.org'},
  org_default_notes_file ='~/coding-playground/java/aeron/notes.org',
  org_todo_keywords = {'TODO', 'NEXT', '|', 'DONE'},
  mappings = {
    global = {
      org_agenda = ',a',
      org_capture = ',c',
    },
    prefix = ','
  }
})

-------------------------------------------------------------------- orgmode ---}}}
------------------------------------------------------------- telescope.nvim ---{{{

local layout_actions = require "telescope.actions.layout"
require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<c-space>"] = layout_actions.toggle_preview,
        ['<C-S-w>'] = require('telescope.actions').delete_buffer,
      },
      n = {
        ['dd'] = require('telescope.actions').delete_buffer,
      }
    },
    -- border = false, -- uncomment to turn off borders (current implementation is ugly)
    scroll_strategy = 'limit',
    layout_strategy = 'vertical',
    layout_config = {
      horizontal = {
        width = { padding = 0 },
        height = { padding = 0 },
      },
      vertical = {
        results_title = false,
        width = { padding = 0 },
        height = { padding = 0 },
        preview_height = 0.6,
        preview_cutoff = 10,
        prompt_position = "top",
      },
    },
  },
  pickers = {
    live_grep = {
      layout_strategy = 'vertical'
    }
  },
  extensions = {
    -- From https://github.com/nvim-telescope/telescope-fzf-native.nvim/tree/8ec164b541327202e5e74f99bcc5fe5845720e18#telescope-setup-and-configuration
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    }
  }
})

require('telescope').load_extension('fzf')

------------------------------------------------------------- telescope.nvim ---}}}
------------------------------------------------------------------- nvim-cmp ---{{{

-- -- From https://github.com/hrsh7th/nvim-cmp/tree/1001683bee3a52a7b7e07ba9d391472961739c7b#recommended-configuration
-- -- and https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion#nvim-cmp
-- local cmp = require'cmp'

-- cmp.setup({
--   snippet = {
--     -- REQUIRED - you must specify a snippet engine
--     expand = function(args)
--       vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
--       -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
--       -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
--       -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
--     end,
--   },
--   mapping = {
--     ['<C-p>'] = cmp.mapping.select_prev_item(),
--     ['<C-n>'] = cmp.mapping.select_next_item(),
--     ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
--     ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
--     ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
--     -- ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
--     ['<C-e>'] = cmp.mapping({
--       i = cmp.mapping.abort(),
--       c = cmp.mapping.close(),
--     }),
--     -- ['<CR>'] = cmp.mapping.confirm({
--     --   behavior = cmp.ConfirmBehavior.Replace,
--     --   select = true,
--     -- }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
--     -- ['<Tab>'] = function(fallback)
--     --   if cmp.visible() then
--     --     cmp.select_next_item()
--     --   elseif luasnip.expand_or_jumpable() then
--     --     luasnip.expand_or_jump()
--     --   else
--     --     fallback()
--     --   end
--     -- end,
--     -- ['<S-Tab>'] = function(fallback)
--     --   if cmp.visible() then
--     --     cmp.select_prev_item()
--     --   elseif luasnip.jumpable(-1) then
--     --     luasnip.jump(-1)
--     --   else
--     --     fallback()
--     --   end
--     -- end,
--   },
--   sources = cmp.config.sources({
--     { name = 'nvim_lsp' },
--     { name = 'vsnip' }, -- For vsnip users.
--     -- { name = 'luasnip' }, -- For luasnip users.
--     -- { name = 'ultisnips' }, -- For ultisnips users.
--     -- { name = 'snippy' }, -- For snippy users.
--   }, {
--     { name = 'buffer' },
--   })
-- })

-- -- Set configuration for specific filetype.
-- cmp.setup.filetype('gitcommit', {
--   sources = cmp.config.sources({
--     { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it. 
--   }, {
--     { name = 'buffer' },
--   })
-- })

-- -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline('/', {
--   sources = {
--     { name = 'buffer' }
--   }
-- })

-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })

-- -- capabilities is used further below when setting up each of the language
-- -- servers in nvim-lspconfig to update with the additional completion
-- -- capabilities offered by nvim-cmp.
-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

------------------------------------------------------------------- nvim-cmp ---}}}
-- ------------------------------------------------------------- nvim-lspconfig ---{{{

-- -- From https://github.com/neovim/nvim-lspconfig/tree/cdc2ec53e028d32f06c51ef8b2837ebb8460ef45#suggested-configuration
-- -- Mappings.
-- -- See `:help vim.diagnostic.*` for documentation on any of the below functions
-- local opts = { noremap=true, silent=true }

-- -- Use an on_attach function to only map the following keys
-- -- after the language server attaches to the current buffer
-- local on_attach = function(client, bufnr)
--   -- Enable completion triggered by <c-x><c-o>
--   vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

--   -- vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
--   -- vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
--   -- vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
--   -- vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

--   -- Mappings.
--   -- See `:help vim.lsp.*` for documentation on any of the below functions
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
--   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
--   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
--   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
--   -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
--   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
-- end

-- ------------------------------------------------------------------------- go ---{{{
-- -- From https://github.com/neovim/nvim-lspconfig/blob/cdc2ec53e028d32f06c51ef8b2837ebb8460ef45/doc/server_configurations.md#gopls
-- require('lspconfig').gopls.setup({
--   capabilities = capabilities,

--   on_attach = on_attach,
--   flags = {
--     -- This will be the default in neovim 0.7+
--     debounce_text_changes = 150,
--   },
-- })
-- ------------------------------------------------------------------------- go ---}}}

-- ---------------------------------------------------------------------- c/c++ ---{{{
-- -- From https://github.com/neovim/nvim-lspconfig/blob/cdc2ec53e028d32f06c51ef8b2837ebb8460ef45/doc/server_configurations.md#clangd
-- require('lspconfig').clangd.setup({
--   capabilities = capabilities,

--   on_attach = on_attach,
--   flags = {
--     -- This will be the default in neovim 0.7+
--     debounce_text_changes = 150,
--   },
-- })
-- ---------------------------------------------------------------------- c/c++ ---}}}

-- ----------------------------------------------------------------------- rust ---{{{
-- -- From https://github.com/neovim/nvim-lspconfig/blob/cdc2ec53e028d32f06c51ef8b2837ebb8460ef45/doc/server_configurations.md#rust_analyzer
-- require('lspconfig').rust_analyzer.setup({
--   capabilities = capabilities,

--   on_attach = on_attach,
--   flags = {
--     -- This will be the default in neovim 0.7+
--     debounce_text_changes = 150,
--   },
-- })
-- ----------------------------------------------------------------------- rust ---}}}

-- ------------------------------------------------------------------------ lua ---{{{
-- -- From https://github.com/neovim/nvim-lspconfig/blob/b01782a673f52f68762b2f910e97a186c16af01c/doc/server_configurations.md#sumneko_lua
-- local runtime_path = vim.split(package.path, ';')
-- table.insert(runtime_path, "lua/?.lua")
-- table.insert(runtime_path, "lua/?/init.lua")

-- require'lspconfig'.sumneko_lua.setup {
-- 	capabilities = capabilities,

--   on_attach = on_attach,
--   flags = {
--     -- This will be the default in neovim 0.7+
--     debounce_text_changes = 150,
--   },

--   settings = {
--     Lua = {
--       runtime = {
--         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
--         version = 'LuaJIT',
--         -- Setup your lua path
--         path = runtime_path,
--       },
--       diagnostics = {
--         -- Get the language server to recognize the `vim` global
--         globals = {'vim'},
--       },
--       workspace = {
--         -- Make the server aware of Neovim runtime files
--         library = vim.api.nvim_get_runtime_file("", true),
--       },
--       -- Do not send telemetry data containing a randomized but unique identifier
--       telemetry = {
--         enable = false,
--       },
--     },
--   },
-- }
-- ------------------------------------------------------------------------ lua ---}}}

-- ----------------------------------------------------------------- typescript ---{{{
-- require('lspconfig').tsserver.setup({
--   capabilities = capabilities,

--   on_attach = on_attach,
--   flags = {
--     -- This will be the default in neovim 0.7+
--     debounce_text_changes = 150,
--   },
-- })
-- ----------------------------------------------------------------- typescript ---}}}

-- ------------------------------------------------------------- nvim-lspconfig ---}}}
------------------------------------------------------------ nvim-treesitter ---{{{

-- From https://github.com/nvim-treesitter/nvim-treesitter/tree/cada76c4901e2389c0f82ac11d0c9c61d5205e90
require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  -- ensure_installed = "maintained",

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing
  -- ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- list of language that will be disabled
    -- disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = true,
  },
}

------------------------------------------------------------ nvim-treesitter ---}}}
-- vim:fdm=marker

