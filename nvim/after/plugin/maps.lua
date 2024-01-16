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

-- Something we do so often should not require two keys.
-- normal("<CR>", ':')

-- Center the screen when scrolling with C-d/u
normal("<C-d>", "<C-d>zz")
normal("<C-u>", "<C-u>zz")

-- Remap for dealing with word wrap
normal('k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
normal('j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Common Buffer stuff that we do all the time.
leader('bp', '<cmd>BufferLineTogglePin<CR>', "[P]in Buffer")
leader('bP', '<cmd>BufferLineGroupClose ungrouped<CR>', "Close Un[P]inned Buffers")
leader('bw', '<CMD>w<CR>', '[W]rite Buffer')
leader('bq', function() require('bufdelete').bufdelete(0, true) end, '[Q]uit Buffer')
leader('bQ', '<CMD>BufferLineCloseOthers<CR>', '[Q]uit Other Buffer')
leader('bo', 'zR', '[O]pen Buffer Folds')
leader('bf', '<CMD>set foldlevel=1<CR>', '[F]old Buffer Folds')
leader('bs', '<CMD>Spectre %<CR>', '[S]pectre in buffer')

leader('b1', '<cmd>BufferLineGoToBuffer 1<CR>', "Go to 1")
leader('b2', '<cmd>BufferLineGoToBuffer 2<CR>', "Go to 2")
leader('b3', '<cmd>BufferLineGoToBuffer 3<CR>', "Go to 3")
leader('b4', '<cmd>BufferLineGoToBuffer 4<CR>', "Go to 4")
leader('b5', '<cmd>BufferLineGoToBuffer 5<CR>', "Go to 5")
leader('b6', '<cmd>BufferLineGoToBuffer 6<CR>', "Go to 6")
leader('b7', '<cmd>BufferLineGoToBuffer 7<CR>', "Go to 7")
leader('b8', '<cmd>BufferLineGoToBuffer 8<CR>', "Go to 8")
leader('b9', '<cmd>BufferLineGoToBuffer 9<CR>', "Go to 9")

normal("]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer"})
normal("[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer"})
normal("<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer"})
normal("<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer"})

-- See `:help telescope.builtin`
leader('?', function() require('telescope.builtin').oldfiles() end, '[?] Find recently opened files')
leader('/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, '[/] Fuzzily search in current buffer')

-- Find stuff
leader('ff', function() require('telescope.builtin').find_files() end, '[F]ind [F]iles')
leader('fb', function() require("telescope.builtin").current_buffer_fuzzy_find({ sorter = require('telescope.sorters').get_substr_matcher({})}) end, '[F]ind in [B]uffers')
leader('fB', function() require('telescope.builtin').buffers() end, '[F]ind in [B]uffers')
-- leader('fh', require('telescope.builtin').help_tags, '[F]ind [H]elp')
leader('fw', function() require('telescope.builtin').grep_string() end, '[F]ind current [W]ord')
leader('fg', function() require('telescope.builtin').live_grep() end, '[F]ind by [G]rep')
leader('fd', function() require('telescope.builtin').diagnostics() end, '[F]ind [D]iagnostics')
leader('fh', '<CMD>Telescope commander<CR>', '[F]ind [H]ygge Commands')
leader('ft', function () require('telescope.builtin').lsp_dynamic_workspace_symbols({ symbols='class', fname_width=0}) end , '[F]ind [T]ype')

-- Diagnostic keymaps
normal('[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
normal(']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
leader('e', vim.diagnostic.open_float, "Open floating diagnostic message")
leader('q', vim.diagnostic.setloclist, "Open diagnostics list")

-- neo-tree
leader('p', '<CMD>NeoTreeFloatToggle<CR>')
leader('P', '<CMD>NeoTreeFocusToggle<CR>')

-- debugging
normal('<F5>', function() require('dap').continue() end, { desc = "Debug: Continue" })
normal('<F9>', function() require('dap').toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })
normal('<F10>', function() require('dap').step_over() end, { desc = "Debug: Step over" })
normal('<F11>', function() require('dap').step_into() end, { desc = "Debug: Step into" })
normal('<F12>', function() require('dap').step_out() end, { desc = "Debug: Step out" })
normal('<F8>', function() require('dap').repl.open() end, { desc = "Debug: Repl" })

-- code
leader('ca', function() require("actions-preview").code_actions() end, "Actions")
leader('cn', vim.lsp.buf.rename, "Rename")
leader('ci', vim.lsp.buf.implementation, "Goto Implementation")
leader('cd', vim.lsp.buf.definition, "Goto Definition")
leader('cb', "<CMD>TroubleToggle document_diagnostics<CR>", "Buffer Diagnostics")
leader('cw', "<CMD>TroubleToggle workspace_diagnostics<CR>", "Workspace Diagnostics")
normal('gr', "<CMD>Trouble lsp_references<CR>", { desc = "Go To References" })
leader('cr', "<CMD>TroubleToggle lsp_references<CR>", "References")
leader('cm', function()
  vim.cmd([[wa]])
  vim.cmd([[FloatermNew --height=0.6 --width=0.8 --wintype=float --name=build --title=build --position=bottomright --autoclose=0 dotnet build]])
end, "Make")
leader('ct', "<CMD>FloatermNew --height=0.6 --width=0.8 --wintype=float --name=adhoc --title=adhoc --position=bottomright --autoclose=2<CR>", "Terminal")

-- test
leader('tn', function()
  vim.cmd([[wa]])
  require("neotest").run.run()
end, "Run [N]earest")

leader('td', function()
  vim.cmd([[wa]])
  require("neotest").run.run({strategy = "dap"})
end, "[D]ebug Nearest")

leader('tl', function()
  vim.cmd([[wa]])
  require("neotest").run.run_last()
end, "Run [L]ast")

leader('tf', function()
  vim.cmd([[wa]])
  require("neotest").run.run(vim.fn.expand("%"))
end, "Run [F]ile")

leader('ts', function()
  vim.cmd([[wa]])
  require("neotest").summary.toggle()
end, "Toggle [S]ummary");

leader('to', function()
  vim.cmd([[wa]])
  require("neotest").output.open({ enter = true })
end, "[O]utput");


-- copilot
leader('cc', "<CMD>Copilot suggestion<CR>", "[C]opilot")
leader('cp', "<CMD>Copilot panel<CR>", "Copilot [P]anel")
leader('cP', "<CMD>Copilot panel refresh<CR>", "Copilot [P]anel Refresh")
leader('cl', "<CMD>Copilot panel accept<CR>", "Copilot Panel Accept")

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
