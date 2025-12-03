return {
  "olimorris/codecompanion.nvim",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
    "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } }, -- Optional: For prettier markdown rendering
    { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves `vim.ui.select`
  },
  -- config = true,
  opts = {
    strategies = {
      chat = {
        adapter = "anthropic",
        slash_commands = {
          ["file"] = {
            -- Location to the slash command in CodeCompanion
            callback = "strategies.chat.slash_commands.file",
            description = "Select a file using Telescope",
            opts = {
              provider = "fzf_lua", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
              contains_code = true,
            },
          },
        },
      },
      inline = {
        adapter = "anthropic",
      },
    },
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "CODECOMPANION_ANTHROPIC_API_KEY",
          },
        })
      end,
    },
  },
}
