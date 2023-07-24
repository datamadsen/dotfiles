vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Don't show the dumb matching stuff.
vim.opt.shortmess:append "c"

-- Complextras.nvim configuration
vim.api.nvim_set_keymap(
    "i",
    "<C-x><C-m>",
    [[<c-r>=luaeval("require('complextras').complete_matching_line()")<CR>]],
    { noremap = true }
)

vim.api.nvim_set_keymap(
    "i",
    "<C-x><C-d>",
    [[<c-r>=luaeval("require('complextras').complete_line_from_cwd()")<CR>]],
    { noremap = true }
)

local ok, lspkind = pcall(require, "lspkind")
if not ok then
    return
end

lspkind.init {
    symbol_map = {
        Copilot = "",
    },
}
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

local cmp = require "cmp"

cmp.setup {
    mapping = {
        ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<c-y>"] = cmp.mapping(
            cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            },
            { "i", "c" }
        ),
        ["<M-y>"] = cmp.mapping(
            cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
            },
            { "i", "c" }
        ),
        ["<c-space>"] = cmp.mapping {
            i = cmp.mapping.complete(),
            c = function(
                _ --[[fallback]]
            )
                if cmp.visible() then
                    if not cmp.confirm { select = true } then
                        return
                    end
                else
                    cmp.complete()
                end
            end,
        },
        ["<tab>"] = cmp.config.disable,
    },

    sources = cmp.config.sources({
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "copilot" },
        { name = "eruby" },
    }, {
        { name = "path" },
        { name = "buffer", keyword_length = 5 },
    }),

    -- sorting = {
    --     comparators = {
    --         cmp.config.compare.score,
    --         cmp.config.compare.kind,
    --         cmp.config.compare.offset,
    --         cmp.config.compare.exact,
    --         cmp.config.compare.sort_text,
    --         cmp.config.compare.length,
    --         cmp.config.compare.order,
    --     },
    -- },

    -- Youtube: mention that you need a separate snippets plugin
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },

    formatting = {
        -- Youtube: How to set up nice formatting for your sources.
        format = lspkind.cmp_format {
            with_text = true,
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                path = "[path]",
                luasnip = "[snip]",
                gh_issues = "[issues]",
                tn = "[TabNine]",
                eruby = "[erb]",
            },
        },
    },
}
