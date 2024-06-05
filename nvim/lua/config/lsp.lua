local M = {}

function M.post()
  local lsp = require('lsp-zero')

  lsp.on_attach(function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
      require('nvim-navic').attach(client, bufnr)
    end

    client.server_capabilities.semanticTokensProvider = nil
  end)

  -- (Optional) Configure lua language server for neovim
  require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

  lsp.configure("omnisharp", {
    cmd = { 'dotnet', '/Users/tmadsen/.cache/omnisharp-osx-arm64-net6.0/OmniSharp.dll', '--languageserver' },
    enable_roslyn_analyzers = true,
    enable_import_completion = true,
    organize_imports_on_format = true,
    handlers = {
      ["textDocument/definition"] = require('omnisharp_extended').handler,
    },
  })

  lsp.setup()

  -- nvim-cmp setup
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  luasnip.config.setup {}

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete {},
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    },
  }
end

return M
