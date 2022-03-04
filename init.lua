------------------------------------------------------------- telescope.nvim ---{{{

local layout_actions = require "telescope.actions.layout"
require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<c-space>"] = layout_actions.toggle_preview,
      }
    },
    -- border = false, -- uncomment to turn off borders (current implementation is ugly)
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
  }
})

------------------------------------------------------------- telescope.nvim ---}}}
-- vim:fdm=marker
