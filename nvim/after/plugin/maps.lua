local function normal(lhs, rhs, opts)
  vim.keymap.set('n', lhs, rhs, opts)
end

local function visual(lhs, rhs, opts)
  vim.keymap.set('v', lhs, rhs, opts)
end

local function leader(lhs, rhs, description)
  vim.keymap.set('n', '<leader>' .. lhs, rhs, { desc = description })
end

-- Keymaps for better default experience
normal('<Space>', '<Nop>', { silent = true })
visual('<Space>', '<Nop>', { silent = true })

normal("<C-d>", "<C-d>zz")
normal("<C-u>", "<C-u>zz")

-- Remap for dealing with word wrap
normal('k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
normal('j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- See `:help telescope.builtin`
leader('?', require('telescope.builtin').oldfiles, '[?] Find recently opened files')
leader('<space>', require('telescope.builtin').buffers, '[ ] Find existing buffers')
leader('/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, '[/] Fuzzily search in current buffer')

leader('ff', require('telescope.builtin').find_files, '[F]ind [F]iles')
-- leader('fh', require('telescope.builtin').help_tags, '[F]ind [H]elp')
leader('fw', require('telescope.builtin').grep_string, '[F]ind current [W]ord')
leader('fg', require('telescope.builtin').live_grep, '[F]ind by [G]rep')
leader('fd', require('telescope.builtin').diagnostics, '[F]ind [D]iagnostics')
leader('fh', '<CMD>Telescope commander<CR>', '[F]ind [T]ims Commands')
leader('ft', function () require('telescope.builtin').lsp_dynamic_workspace_symbols({ symbols='class', fname_width=0}) end , '[F]ind [T]ype')

-- Diagnostic keymaps
normal('[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
normal(']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
leader('e', vim.diagnostic.open_float, "Open floating diagnostic message")
leader('q', vim.diagnostic.setloclist, "Open diagnostics list")

-- neo-tree
leader('p', '<CMD>NeoTreeFloatToggle<CR>')
leader('P', '<CMD>NeoTreeShowToggle<CR>')

-- debuggingr
normal('<F5>', require('dap').continue, { desc = "Debug: Continue" })
normal('<F9>', require('dap').toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
normal('<F10>', require('dap').step_over, { desc = "Debug: Step over" })
normal('<F11>', require('dap').step_into, { desc = "Debug: Step into" })
normal('<F12>', require('dap').step_out, { desc = "Debug: Step out" })
normal('<F8>', require('dap').repl.open, { desc = "Debug: Repl" })

-- code
-- leader('ca', '<CMD>CodeActionMenu<CR>', "Actions") -- not so nice.
leader('ca', vim.lsp.buf.code_action, "Actions")
leader('cr', vim.lsp.buf.rename, "Rename")
leader('ci', vim.lsp.buf.implementation, "Goto Implementation");
leader('cd', vim.lsp.buf.definition, "Goto Definition");
leader('cb', "<CMD>TroubleToggle document_diagnostics<CR>", "Buffer Diagnostics");
leader('cw', "<CMD>TroubleToggle workspace_diagnostics<CR>", "Workspace Diagnostics");
leader('cr', "<CMD>TroubleToggle lsp_references<CR>", "References");
normal(']d', function() vim.diagnostic.goto_next({ float = false }) end)
normal('[d', function() vim.diagnostic.goto_prev({ float = false }) end)
normal('<C-s>', "<CMD>Telescope lsp_document_symbols theme=dropdown previewer=false<CR>");
normal('<C-t>', "<CMD>Telescope lsp_workspace_symbols<CR>");

-- Search and replace
normal('<leader>so', '<cmd>lua require("spectre").open()<CR>', {
  desc = "[S]pectre: [O]pen"
})
normal('<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "[S]pectre: Search current [w]ord"
})
visual('<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
  desc = "[S]pectre: Search current [w]ord"
})
normal('<leader>sf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
  desc = "[S]pectre: Search in current [f]ile"
})
