-- Note: We are not using lazy.nvim as package manager (yet) because that
--       conflicts with vim-plug. To install Lua-only plugin, we still add it
--       to init.vim, but add the configuration in this file.

--- telescope.nvim 

---- telescope.nvim: layout_strategies

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

-- YJ: Currently this layout strategy is only properly configured for prompt_position == bottom
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

    if vim.opt.laststatus:get() == 2 then
      max_lines = max_lines + 1
    end

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

    results.line = results.line - 1
    results.height = results.height + 1
    if vim.fn.has("gui_running") == 1 or vim.fn.exists("g:neovide") == 1 then
      prompt.line = prompt.line - 1
    end

    -- YJ: Fix bug (seems to only appear on Linux Mint, and in certain screen
    -- sizez) where bottom-most results line is behind the prompt and hence
    -- can't be seen.
    if not self.previewer then
      results.line = results.line - 1
      results.height = results.height - 1
    end

    return {
      preview = self.previewer and preview.height > 0 and preview,
      results = results,
      prompt = prompt,
    }
  end
)

---- telescope.nvim: general configurations

local layout_actions = require "telescope.actions.layout"
require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<c-space>"] = layout_actions.toggle_preview,
        ['<C-S-w>']   = require('telescope.actions').delete_buffer,
        ["<c-a>"]     = { "<home>", type = "command" },
        ["<c-e>"]     = { "<end>" , type = "command" },
      },
      n = {
        ['dd'] = require('telescope.actions').delete_buffer,
      }
    },
    border = false,
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
    },
    telescope_project = {
      layout_strategy = 'yj_vertical_no_gap'
    }
  },
  extensions = {
    -- From https://github.com/nvim-telescope/telescope-fzf-native.nvim/tree/8ec164b541327202e5e74f99bcc5fe5845720e18#telescope-setup-and-configuration
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    }
  }
})

require('telescope').load_extension('fzf')

--- nvim-cmp

-- References;
--  - https://github.com/hrsh7th/nvim-cmp/tree/1001683bee3a52a7b7e07ba9d391472961739c7b#recommended-configuration
--  - https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion#nvim-cmp
local cmp = require('cmp')

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
  enabled = false, -- disabling by default since we ar still mainly using 
                   -- coc.nvim, we can manually enable using the following
                   -- :lua require('cmp').setup.buffer({ enabled = true })
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<C-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }), -- Accept currently selected item. Set `select` to `false` to only 
        -- confirm explicitly selected items.

    -- <Tab> and <S-Tab> mappings are copied from nvim-cmp GitHub wiki: 
    -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#vim-vsnip
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('rust', { enabled = true })
cmp.setup.filetype('lua', { enabled = true })

-- capabilities is used further below when setting up each of the language
-- servers in nvim-lspconfig to update with the additional completion
-- capabilities offered by nvim-cmp.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities =
  vim.tbl_extend('keep', capabilities, require('lsp-status').capabilities)

--- nvim-lspconfig

--- nvim-lspconfig: show virtual text only on current line
--
-- Adapted from config file pointed to by this reddit answer:
--   - https://www.reddit.com/r/neovim/comments/xqsboa/comment/iqdaed7/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
--   - Config files:
--     - https://github.com/alisnic/.dotfiles/blob/e5cd3f0c95132eadf0f8be09c3ce6f585ac9e921/nvim/lua/lsp.lua#L1-L93
--     - https://github.com/alisnic/.dotfiles/blob/e5cd3f0c95132eadf0f8be09c3ce6f585ac9e921/nvim/lua/lsp.lua#L170-L194

vim.diagnostic.config({
  virtual_text = false,
})

local function curr_line_most_severe_diag(diagnostics)
  if vim.tbl_isempty(diagnostics) then return end

  local curr_most_severe = nil
  local line_diagnostics = {}
  local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1

  for k, v in pairs(diagnostics) do
    if v.lnum == line_nr then
      line_diagnostics[k] = v
    end
  end

  for _, diagnostic in ipairs(line_diagnostics) do
    if curr_most_severe == nil then
      curr_most_severe = diagnostic
    elseif diagnostic.severity < curr_most_severe.severity then
      curr_most_severe = diagnostic
    end
  end

  return curr_most_severe
end

local curr_line_diag_ns = vim.api.nvim_create_namespace "current_line_virt"
local virtual_text_handler_orig = vim.diagnostic.handlers.virtual_text

vim.diagnostic.handlers.current_line_virt = {
  show = function(_, bufnr, diagnostics, _)
    local curr_line_diag = curr_line_most_severe_diag(diagnostics)
    if not curr_line_diag then return end
    pcall(
      virtual_text_handler_orig.show,
      curr_line_diag_ns,
      bufnr,
      { curr_line_diag },
      nil
    )
  end,

  hide = function(_, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    virtual_text_handler_orig.hide(curr_line_diag_ns, bufnr)
  end,
}

local curr_line_diag_augroup_name = "curr_line_diag"
vim.api.nvim_create_augroup(curr_line_diag_augroup_name, { clear = true, })

local function set_up_current_line_virtual_text(bufnr)
  if vim.wo.signcolumn == 'auto' then vim.wo.signcolumn = 'yes:1' end

  local current_line_diagnostics = function()
    local curr_buf_nr = 0
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    return vim.diagnostic.get(curr_buf_nr, { ["lnum"] = line_nr })
  end

  vim.api.nvim_clear_autocmds({
    buffer = bufnr,
    group = curr_line_diag_augroup_name
  })

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = curr_line_diag_augroup_name,
    buffer = bufnr,
    callback = function()
      vim.diagnostic.handlers.current_line_virt
        .show(nil, 0, current_line_diagnostics(), nil)
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = curr_line_diag_augroup_name,
    buffer = bufnr,
    callback = function()
      vim.diagnostic.handlers.current_line_virt.hide(nil, nil)
    end,
  })
end

--- nvim-lspconfig: misc (TODO tidy this)

local mapping_opts = { noremap=true, silent=true }

-- Use an on_attach function to only map the following keys after the language
-- server attaches to the current buffer
local on_attach = function(client, bufnr)
  require('lsp-status').on_attach(client)

  set_up_current_line_virtual_text(bufnr)

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc') -- Enable completion triggered by <c-x><c-o>

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', mapping_opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ac', '<cmd>lua vim.lsp.buf.code_action()<CR>', mapping_opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', mapping_opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', mapping_opts)

  -- Telescope mappings
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua require("telescope.builtin").lsp_references()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gco', '<cmd>lua require("telescope.builtin").lsp_outgoing_calls()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gci', '<cmd>lua require("telescope.builtin").lsp_incoming_calls()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua require("telescope.builtin").lsp_implementations()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gy', '<cmd>lua require("telescope.builtin").lsp_type_definitions()<CR>', mapping_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>s', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', mapping_opts)
end

---- nvim-lspconfig: rust
-- From https://github.com/neovim/nvim-lspconfig/blob/cdc2ec53e028d32f06c51ef8b2837ebb8460ef45/doc/server_configurations.md#rust_analyzer
require('lspconfig').rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

---- nvim-lspconfig: lua
-- From https://github.com/neovim/nvim-lspconfig/blob/b01782a673f52f68762b2f910e97a186c16af01c/doc/server_configurations.md#sumneko_lua
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require('lspconfig').lua_ls.setup {
	capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- Tell the language server which version of Lua 
                            -- you're using (most likely LuaJIT in the case of 
                            -- Neovim)
        path = runtime_path, -- Setup your lua path
      },
      diagnostics = {
        globals = {'vim'}, -- Get the language server to recognize the `vim` global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
      },
      telemetry = {
        enable = false,
      }, -- Do not send telemetry data containing a randomized but unique identifier
    },
  },
}

--- nvim-treesitter 

require('nvim-treesitter.configs').setup({
  modules = {}, -- adding to avoid the irritating diagnostic complaining about missing fields

  ensure_installed = {}, -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  sync_install = false, -- Install languages synchronously (only applied to `ensure_installed`)
  auto_install = false, -- Automatically install missing parsers when entering buffer
  ignore_install = {}, -- List of parsers to ignore installing

  highlight = {
    enable = true, -- `false` will disable the whole extension
    disable = {
      "lua", -- For some reason highlight lua is extremely slow
    }, -- list of language that will be disabled

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = {},
  },

  -- From https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
        ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },
        ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@function.inner'] = 'V', -- linewise
        ['@class.outer'] = 'V', -- linewise
        ['@class.inner'] = 'V', -- linewise
      },
      include_surrounding_whitespace = true,
    },

    swap = {
      enable = true,
      swap_next = { ["<leader>an"] = "@parameter.inner" },
      swap_previous = { ["<leader>ap"] = "@parameter.inner" },
    },

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
})

--- neogit

require('neogit').setup {}

-- vim: foldmethod=expr foldexpr=YJ_InitLuaFoldExpr() textwidth=80 colorcolumn=80

