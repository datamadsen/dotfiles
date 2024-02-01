local wk = require("which-key")

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

-- Center the screen when scrolling with C-d/u
normal("<C-d>", "<C-d>zz")
normal("<C-u>", "<C-u>zz")

-- Remap for dealing with word wrap
normal('k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
normal('j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

leader('?', function() require('telescope.builtin').oldfiles() end, 'Recent files')
leader('/',
  function()
    require("telescope.builtin").current_buffer_fuzzy_find({
      sorter = require('telescope.sorters')
          .get_substr_matcher({})
    })
  end, 'Fuzzy search')

wk.register({
  ["<leader>w"] = { "<cmd>w<cr>", "Write buffer" }
})

wk.register({
  ["<leader>j"] = { function() require('telescope.builtin').find_files() end, 'Find Files' },
})

wk.register({
  ["<leader>g"] = { function() require('telescope.builtin').live_grep() end, 'Grep' },
})

-- Common Buffer stuff that we do all the time.
wk.register({
  ["<leader>b"] = {
    name = "+ buffer",
    q = { "<cmd>%bd|e#<cr>", "Quit other buffers" },
    Q = { "<cmd>bd<cr>", "Quit this buffer" },
    w = { "<cmd>w<cr>", "Write" },
    o = { "zR", "Open folds" },
    f = { "zM", "Close folds" }
  }
})

-- Find stuff
wk.register({
  ["<leader>f"] = {
    name = "+ find",
    f    = { function() require('telescope.builtin').find_files() end, 'Files' },
    b    = { function() require('telescope.builtin').buffers({ sort_mru = true, ignore_current_buffer = false }) end, 'Buffers' },
    h    = { function() require('telescope.builtin').help_tags() end, 'Help' },
    w    = { function() require('telescope.builtin').grep_string() end, 'Grep for Word' },
    g    = { function() require('telescope.builtin').live_grep() end, 'Grep' },
    d    = { function() require('telescope.builtin').diagnostics() end, 'Diagnostics' },
    t    = { function() require('telescope.builtin').lsp_dynamic_workspace_symbols({ symbols = { 'class', 'method' } }) end, '[F]ind [T]ype' }
  }
})

-- Diagnostic keymaps
normal('[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
normal(']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })

-- neo-tree
leader('p', '<CMD>NeoTreeFloatToggle<CR>', "Project popup")
leader('P', '<CMD>NeoTreeFocusToggle<CR>', "Project drawer")

-- debugging
normal('<F5>', function() require('dap').continue() end, { desc = "Debug: Continue" })
normal('<F9>', function() require('dap').toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })
normal('<F10>', function() require('dap').step_over() end, { desc = "Debug: Step over" })
normal('<F11>', function() require('dap').step_into() end, { desc = "Debug: Step into" })
normal('<F12>', function() require('dap').step_out() end, { desc = "Debug: Step out" })
normal('<F8>', function() require('dap').repl.open() end, { desc = "Debug: Repl" })

-- code
normal('gr', "<cmd>TroubleToggle lsp_references<gr>", { desc = "Go To References" })
normal('<C-s>', "<CMD>Telescope lsp_document_symbols theme=dropdown previewer=false<CR>");
normal('<C-t>', function() require('telescope.builtin').lsp_dynamic_workspace_symbols({ symbols = 'class' }) end)
wk.register({
  ["<leader>c"] = {
    name = "+ code",
    a = { function() require("actions-preview").code_actions() end, "Actions" },
    n = { vim.lsp.buf.rename, "Rename" },
    i = { vim.lsp.buf.implementation, "Goto Implementation" },
    d = { vim.lsp.buf.definition, "Goto Definition" },
    b = { "<cmd>TroubleToggle document_diagnostics<cr>", "Buffer Diagnostics" },
    w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
    r = { "<cmd>TroubleToggle lsp_references<cr>", "References" },
    m = {
      function()
        vim.cmd([[wa]])
        vim.cmd(
          [[FloatermNew --height=0.6 --width=0.8 --wintype=float --name=build --title=build --position=bottomright --autoclose=0 dotnet build]])
      end, "Make"
    },
    t = { "<CMD>FloatermNew --height=0.6 --width=0.8 --wintype=float --name=adhoc --title=adhoc --position=bottomright --autoclose=2<CR>", "Terminal" },
    s = { "<cmd>FloatermToggle adhoc<cr>", "Toggle adhoc" },
    c = { "<CMD>Copilot suggestion<CR>", "Copilot" },
  }
})

-- testing
wk.register({
  ["<leader>t"] = {
    name = "+ test",
    n = {
      function()
        vim.cmd([[wa]])
        require("neotest").run.run()
      end, "Nearest"
    },

    d = {
      function()
        vim.cmd([[wa]])
        require("neotest").run.run({ strategy = "dap" })
      end, "Debug" },

    l = {
      function()
        vim.cmd([[wa]])
        require("neotest").run.run_last()
      end, "Last" },

    f = {
      function()
        vim.cmd([[wa]])
        require("neotest").run.run(vim.fn.expand("%"))
      end, "File" },

    s = {
      function()
        vim.cmd([[wa]])
        require("neotest").summary.toggle()
      end, "Summary" },

    o = {
      function()
        vim.cmd([[wa]])
        require("neotest").output.open({ enter = true })
      end, "Output" },
  }
})


-- Search and replace
wk.register({
  ["<leader>s"] = {
    name = "+ Search / Replace",
    o = { function() require('spectre').open() end, "Open spectre" },
    w = { function() require('spectre').open_visual({ select_word = true }) end, "Spectre word under cursor" },
    f = { function() require('spectre').open_file_search({ select_word = true }) end, "Spectre word under cursor, file" },
  }
})

-- Miscellaneous
wk.register({
  ["<leader>m"] = {
    name = "+ miscellaneous",
    f = {
      name = "+ folding",
      m = {
        function()
          vim.cmd([[
                    set foldmethod=manual
                    set foldexpr=0
                ]])
        end, "Manual" },
      t = {
        function()
          vim.cmd([[
                    set foldmethod=expr
                    set foldexpr=nvim_treesitter#foldexpr()
                ]])
        end, "Treesitter"
      }
    },
    g = {
      function()
        vim.cmd([[wa]])
        vim.cmd([[FloatermNew --height=0.8 --width=0.8 --title=git --wintype=float lazygit]])
      end, "Git"
    },
    q = { "<cmd>wqa<cr>", "Write all and quit" },
    w = { "<cmd>wa<cr>", "Write all" },
    y = { function() require("telescope").extensions.yank_history.yank_history({}) end, "Yank history" },
  }
})
