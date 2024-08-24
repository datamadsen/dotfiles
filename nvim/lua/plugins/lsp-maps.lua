return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      omnisharp = {
        keys = {
          {
            "<leader>cm",
            function()
              vim.cmd([[wa]])
              vim.cmd(
                [[FloatermNew --height=0.6 --width=0.8 --wintype=float --name=build --title=build --position=bottomright --autoclose=0 dotnet build]]
              )
            end,
            desc = "Make",
          },
          {
            "<leader>cg",
            function()
              require("fzf-lua").lsp_live_workspace_symbols()
            end,
            desc = "Go To Everything",
          },
          {
            "<leader>cu",
            function()
              require("fzf-lua").lsp_references()
            end,
            desc = "References",
          },
          {
            "gi",
            function()
              require("fzf-lua").lsp_implementation()
            end,
            desc = "Go To Implementation",
          },
        },
      },
    },
  },
}
