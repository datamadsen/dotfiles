return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      omnisharp = {
        -- README:
        -- If Mason updated omnisharp then it probably selected the wrong architecture.
        -- see: https://github.com/williamboman/mason.nvim/discussions/1651
        -- run: MasonInstall --target=darwin_arm64 omnisharp

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
