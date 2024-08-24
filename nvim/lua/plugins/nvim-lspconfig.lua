return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      omnisharp = {
        -- cmd = { "dotnet", "/Users/tmadsen/.cache/omnisharp-osx-arm64-net6.0/OmniSharp.dll", "--languageserver" },
        -- enable_roslyn_analyzers = true,
        -- enable_import_completion = true,
        -- organize_imports_on_format = true,
        -- handlers = {
        --   ["textDocument/definition"] = require("omnisharp_extended").handler,
        -- },
      },
    },
  },
}
