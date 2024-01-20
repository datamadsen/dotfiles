local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ["<esc>"] = actions.close
      },
    },
    layout_config = {
      prompt_position = "top",
      anchor = "NW"
    },
  },
  pickers = {
    lsp_document_symbols = {
      theme = "dropdown",
      preview = false,
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
  }
}
