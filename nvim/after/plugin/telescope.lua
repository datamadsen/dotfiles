local command_center = require("command_center")

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
    -- path_display = "hidden",
  },
  pickers = {
    lsp_document_symbols = {
      theme = "dropdown",
      preview = false,
      on_input_filter_cb = function(prompt)
        return { prompt = prompt }
      end
    },
    lsp_workspace_symbols = {
      path_display = "hidden",
      on_input_filter_cb = function(prompt)
        return { prompt = prompt }
      end
    }
  },
  extensions = {
    command_center = {
      components = {
        command_center.component.DESC,
      },
      sort_by = {
        command_center.component.DESC,
      },
      auto_replace_desc_with_cmd = false,
      prompt_title = 'Tims HyggeCommands'
    }
  }
}
