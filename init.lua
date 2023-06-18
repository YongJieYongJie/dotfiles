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

--------------------------- Adapted from telescope.pickers.layout_strategies --{{{{

-- This code section belows defines a custom Telescope layout with the
-- following properties:
--  1. No pointless gaps
--  2. No status line
--
--  Most of the code is copied directly from
--  telescope.pickers.layout_strategies (because they can't be imported), and
--  only the code inside the `make_documented_layout` call is tweaked.

local layout_strategies = require "telescope.pickers.layout_strategies"
local resolve = require "telescope.config.resolve"
local p_window = require "telescope.pickers.window"

local adjust_pos = function(pos, ...)
  for _, opts in ipairs { ... } do
    opts.col = opts.col and opts.col + pos[1]
    opts.line = opts.line and opts.line + pos[2]
  end
end

local shared_options = {
  width = { "How wide to make Telescope's entire layout", "See |resolver.resolve_width()|" },
  height = { "How tall to make Telescope's entire layout", "See |resolver.resolve_height()|" },
  mirror = "Flip the location of the results/prompt and preview windows",
  scroll_speed = "The number of lines to scroll through the previewer",
  prompt_position = { "Where to place prompt window.", "Available Values: 'bottom', 'top'" },
  anchor = { "Which edge/corner to pin the picker to", "See |resolver.resolve_anchor_pos()|" },
}

--@param strategy_config table: table with keys for each option for a strategy
--@return table: table with keys for each option (for this strategy) and with keys for each layout_strategy
local get_valid_configuration_keys = function(strategy_config)
  local valid_configuration_keys = {
    -- TEMP: There are a few keys we should say are valid to start with.
    preview_cutoff = true,
    prompt_position = true,
  }

  for key in pairs(strategy_config) do
    valid_configuration_keys[key] = true
  end

  for name in pairs(layout_strategies) do
    valid_configuration_keys[name] = true
  end

  return valid_configuration_keys
end

--@param strategy_name string: the name of the layout_strategy we are validating for
--@param configuration table: table with keys for each option available
--@param values table: table containing all of the non-default options we want to set
--@param default_layout_config table: table with the default values to configure layouts
--@return table: table containing the combined options (defaults and non-defaults)
local function validate_layout_config(strategy_name, configuration, values, default_layout_config)
  assert(strategy_name, "It is required to have a strategy name for validation.")
  local valid_configuration_keys = get_valid_configuration_keys(configuration)

  -- If no default_layout_config provided, check Telescope's config values
  default_layout_config = vim.F.if_nil(default_layout_config, require("telescope.config").values.layout_config)

  local result = {}
  local get_value = function(k)
    -- skip "private" items
    if string.sub(k, 1, 1) == "_" then
      return
    end

    local val
    -- Prioritise options that are specific to this strategy
    if values[strategy_name] ~= nil and values[strategy_name][k] ~= nil then
      val = values[strategy_name][k]
    end

    -- Handle nested layout config values
    if layout_strategies[k] and strategy_name ~= k and type(val) == "table" then
      val = vim.tbl_deep_extend("force", default_layout_config[k], val)
    end

    if val == nil and values[k] ~= nil then
      val = values[k]
    end

    if val == nil then
      if default_layout_config[strategy_name] ~= nil and default_layout_config[strategy_name][k] ~= nil then
        val = default_layout_config[strategy_name][k]
      else
        val = default_layout_config[k]
      end
    end

    return val
  end

  -- Always set the values passed first.
  for k in pairs(values) do
    if not valid_configuration_keys[k] then
      -- TODO: At some point we'll move to error here,
      --    but it's a bit annoying to just straight up crash everyone's stuff.
      vim.api.nvim_err_writeln(
        string.format(
          "Unsupported layout_config key for the %s strategy: %s\n%s",
          strategy_name,
          k,
          vim.inspect(values)
        )
      )
    end

    result[k] = get_value(k)
  end

  -- And then set other valid keys via "inheritance" style extension
  for k in pairs(valid_configuration_keys) do
    if result[k] == nil then
      result[k] = get_value(k)
    end
  end

  return result
end

--@param name string: the name to be assigned to the layout
--@param layout_config table: table where keys are the available options for the layout
--@param layout function: function with signature
--          function(self, max_columns, max_lines, layout_config): table
--        the returned table is the sizing and location information for the parts of the picker
--@retun function: wrapped function that inputs a validated layout_config into the `layout` function
local function make_documented_layout(name, layout_config, layout)
  -- Save configuration data to be used by documentation
  layout_strategies._configurations[name] = layout_config

  -- Return new function that always validates configuration
  return function(self, max_columns, max_lines, override_layout)
    return layout(
      self,
      max_columns,
      max_lines,
      validate_layout_config(
        name,
        layout_config,
        vim.tbl_deep_extend("keep", vim.F.if_nil(override_layout, {}), vim.F.if_nil(self.layout_config, {}))
      )
    )
  end
end

local calc_tabline = function(max_lines)
  local tbln = (vim.o.showtabline == 2) or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
  if tbln then
    max_lines = max_lines - 1
  end
  return max_lines, tbln
end

-- Helper function for capping over/undersized width/height, and calculating spacing
--@param cur_size number: size to be capped
--@param max_size any: the maximum size, e.g. max_lines or max_columns
--@param bs number: the size of the border
--@param w_num number: the maximum number of windows of the picker in the given direction
--@param b_num number: the number of border rows/column in the given direction (when border enabled)
--@param s_num number: the number of gaps in the given direction (when border disabled)
local calc_size_and_spacing = function(cur_size, max_size, bs, w_num, b_num, s_num)
  local spacing = s_num * (1 - bs) + b_num * bs
  cur_size = math.min(cur_size, max_size)
  cur_size = math.max(cur_size, w_num + spacing)
  return cur_size, spacing
end

layout_strategies.yj_vertical_no_gap = make_documented_layout(
  "yj_vertical_no_gap",
  vim.tbl_extend("error", shared_options, {
    preview_cutoff = "When lines are less than this value, the preview will be disabled",
    preview_height = { "Change the height of Telescope's preview window", "See |resolver.resolve_height()|" },
  }),
  function(self, max_columns, max_lines, layout_config)
    local initial_options = p_window.get_initial_window_options(self)
    local preview = initial_options.preview
    local results = initial_options.results
    local prompt = initial_options.prompt

    local tbln
    max_lines, tbln = calc_tabline(max_lines)
    max_lines = max_lines + 1

    local width_opt = layout_config.width
    local width = resolve.resolve_width(width_opt)(self, max_columns, max_lines)

    local height_opt = layout_config.height
    local height = resolve.resolve_height(height_opt)(self, max_columns, max_lines)

    local bs = 0 -- border_size

    local w_space
    -- Cap over/undersized width
    width, w_space = calc_size_and_spacing(width, max_columns, bs, 1, 2, 0)

    prompt.width = width - w_space
    results.width = prompt.width
    preview.width = prompt.width

    local h_space
    if self.previewer and max_lines >= layout_config.preview_cutoff then
      -- Cap over/undersized height (with previewer)
      height, h_space = calc_size_and_spacing(height, max_lines, bs, 3, 6, 1)

      preview.height =
        resolve.resolve_height(vim.F.if_nil(layout_config.preview_height, 0.5))(self, max_columns, height)
    else
      -- Cap over/undersized height (without previewer)
      height, h_space = calc_size_and_spacing(height, max_lines, bs, 2, 4, 1)

      preview.height = 0
    end
    prompt.height = 1
    results.height = height - preview.height - prompt.height - h_space

    local width_padding = math.floor((max_columns - width) / 2) + bs + 1
    results.col, preview.col, prompt.col = width_padding, width_padding, width_padding

    local height_padding = math.floor((max_lines - height) / 2)
    if not layout_config.mirror then
      preview.line = height_padding + (1 + bs)
      if layout_config.prompt_position == "top" then
        prompt.line = (preview.height == 0) and preview.line or preview.line + preview.height + (1 + bs)
        results.line = prompt.line + prompt.height + (1 + bs)
      elseif layout_config.prompt_position == "bottom" then
        results.line = (preview.height == 0) and (preview.line + 1) or preview.line + preview.height + (1 + bs)
        prompt.line = results.line + results.height + (1 + bs)
      else
        error(string.format("Unknown prompt_position: %s\n%s", self.window.prompt_position, vim.inspect(layout_config)))
      end
    else
      if layout_config.prompt_position == "top" then
        prompt.line = height_padding + (1 + bs)
        results.line = prompt.line + prompt.height + (1 + bs)
        preview.line = results.line + results.height + (1 + bs)
      elseif layout_config.prompt_position == "bottom" then
        results.line = height_padding + (1 + bs)
        prompt.line = results.line + results.height + (1 + bs)
        preview.line = prompt.line + prompt.height + (1 + bs)
      else
        error(string.format("Unknown prompt_position: %s\n%s", self.window.prompt_position, vim.inspect(layout_config)))
      end
    end

    local anchor_pos = resolve.resolve_anchor_pos(layout_config.anchor or "", width, height, max_columns, max_lines)
    adjust_pos(anchor_pos, prompt, results, preview)

    if tbln then
      prompt.line = prompt.line + 1
      results.line = results.line + 1
      preview.line = preview.line + 1
    end

    return {
      preview = self.previewer and preview.height > 0 and preview,
      results = results,
      prompt = prompt,
    }
  end
)
--------------------------- Adapted from telescope.pickers.layout_strategies --}}}}}

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
    border = false, -- uncomment to turn off borders (current implementation is ugly)
    scroll_strategy = 'limit',
    layout_strategy = 'yj_vertical_no_gap',
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
      yj_vertical_no_gap = {
        results_title = false,
        width = { padding = 0 },
        height = { padding = 0 },
        preview_height = 0.7,
        preview_cutoff = 10,
        prompt_position = "bottom",
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

-- From https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/f27f22053d210191e0a267ca15ec80a10a226a97#text-objects-select
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = true,
    },
  },
}

-- From https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/f27f22053d210191e0a267ca15ec80a10a226a97#text-objects-swap
require'nvim-treesitter.configs'.setup {
  textobjects = {
    swap = {
      enable = true,
      swap_next = {
        ["<leader>an"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>Ap"] = "@parameter.inner",
      },
    },
  },
}

-- From https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/f27f22053d210191e0a267ca15ec80a10a226a97#text-objects-move
require'nvim-treesitter.configs'.setup {
  textobjects = {
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}

------------------------------------------------------------ nvim-treesitter ---}}}
-- vim:fdm=marker

