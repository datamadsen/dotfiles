local actions = require('telescope.actions')
local actions_layout = require('telescope.actions.layout')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ["<esc>"] = actions.close
      },
      n = {
        ['p'] = actions_layout.toggle_preview,
      }
    },
    layout_strategy = "cursor",
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
  },
  pickers = {
    lsp_document_symbols = {
      theme = "dropdown",
      preview = false,
      on_input_filter_cb = function(prompt)
        return { prompt = prompt }
      end
    },
    lsp_implementations = {
      layout_config = {
        prompt_position = "top",
        width = 0.9,
      },
      initial_mode = "normal",
      layout_strategy = "cursor",
      theme = "cursor",
      title = "implementations",
      preview = {
        hide_on_startup = true,
      },
      show_line = false,
      path_display = function(opts, path)
        local tail = require("telescope.utils").path_tail(path)
        path = string.format("%s", tail)

        local highlights = {
          {
            {
              0,       -- highlight start position
              #path,   -- highlight end position
            },
            "include", -- highlight group name
          },
          {
            {
              #path,   -- highlight start position
              100,     -- highlight end position
            },
            "conceal", -- highlight group name
          },
        }

        return path, highlights
      end,
      on_input_filter_cb = function(prompt)
        return { prompt = prompt }
      end
    },
    lsp_dynamic_workspace_symbols = {
      path_display = "hidden",
      theme = "dropdown",
      prompt_title = "Find Symbol",
      previewer = false,
      on_input_filter_cb = function(prompt)
        return { prompt = prompt }
      end
    }
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_cursor {
        -- even more opts
      }
    }
  }
}
require("telescope").load_extension("ui-select")
