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

-- Root keymaps
wk.add({
  { "<leader>w", "<cmd>w<cr>", desc = "Write buffer" },
  { "<leader>j", function() require('telescope.builtin').find_files() end, desc = 'Find Files' },
  { "<leader>g", function() require('telescope.builtin').live_grep() end, desc = 'Grep' }
})

-- Common Buffer stuff that we do all the time.
wk.add({
  {"<leader>b",  group = "+ Buffer", },
  {"<leader>bq", "<cmd>%bd|e#<cr>", desc = "Quit other buffers" },
  {"<leader>bQ", "<cmd>bd<cr>",     desc = "Quit this buffer" },
  {"<leader>bw", "<cmd>w<cr>",      desc = "Write" },
  {"<leader>bo", "zR",              desc = "Open folds" },
  {"<leader>bf", "zM",              desc = "Close folds" },
})


-- Find stuff
wk.add({
  {"<leader>f",  group = '+ Find' },
  {"<leader>ff", function() require('telescope.builtin').find_files() end, desc = 'Files' },
  {"<leader>fb", function() require('telescope.builtin').buffers({ sort_mru = true, ignore_current_buffer = false }) end, desc = 'Buffers' },
  {"<leader>fh", function() require('telescope.builtin').help_tags() end, desc = 'Help' },
  {"<leader>fw", function() require('telescope.builtin').grep_string() end, desc = 'Grep for Word' },
  {"<leader>fg", function() require('telescope.builtin').live_grep() end, desc = 'Grep' },
  {"<leader>fd", function() require('telescope.builtin').diagnostics() end, desc = 'Diagnostics' },
  {"<leader>ft", function() require('telescope.builtin').lsp_dynamic_workspace_symbols({ symbols = { 'class', 'method' } }) end, desc = '[F]ind [T]ype' }
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
normal('gr', "<cmd>Telescope lsp_references<cr>", { desc = "Go To References" })
normal('gi', "<cmd>Telescope lsp_implementations<cr>", { desc = "Go To Implementations" })
normal('gd', "<cmd>Telescope lsp_definitions<cr>", { desc = "Go To Implementations" })
normal('<C-s>', "<CMD>Telescope lsp_document_symbols theme=dropdown previewer=false<CR>");
normal('<C-t>', function() require('telescope.builtin').lsp_dynamic_workspace_symbols({ symbols = 'class' }) end)
-- code
wk.add({
  { "<leader>c", group = "+ Code"},
  { "<leader>ca", vim.lsp.buf.code_action, desc = "Actions" },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
  { "<leader>ci", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
  { "<leader>cd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
  { "<leader>cD", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
  { "<leader>cu", "<cmd>Trouble lsp_references<cr>", desc = "Usages" },
  { "<leader>c.", "<cmd>LspRestart<cr>", desc = "Restart LSP" },
  { "<leader>cm",
    function()
      vim.cmd([[wa]])
      vim.cmd( [[FloatermNew --height=0.6 --width=0.8 --wintype=float --name=build --title=build --position=bottomright --autoclose=0 dotnet build]])
    end, desc = "Make" },
  { "<leader>ct", "<CMD>FloatermNew --height=0.6 --width=0.8 --wintype=float --name=adhoc --title=adhoc --position=bottomright --autoclose=2<CR>", desc = "Terminal" },
  { "<leader>cs", "<cmd>FloatermToggle adhoc<cr>", desc = "Toggle adhoc" },
  { "<leader>cc", "<CMD>Copilot suggestion<CR>", desc = "Copilot" },
})

-- testing
wk.add({
  {"<leader>t", group = "+ Test"},
  {"<leader>tn",
      function()
        vim.cmd([[wa]])
        require("neotest").run.run()
      end, desc = "Nearest"
    },

    {"<leader>td",
      function()
        vim.cmd([[wa]])
        require("neotest").run.run({ strategy = "dap" })
      end, desc = "Debug" },

    {"<leader>tl",
      function()
        vim.cmd([[wa]])
        require("neotest").run.run_last()
      end, desc = "Last" },

    {"<leader>tf",
      function()
        vim.cmd([[wa]])
        require("neotest").run.run(vim.fn.expand("%"))
      end, desc = "File" },

    {"<leader>ts",
      function()
        vim.cmd([[wa]])
        require("neotest").summary.toggle()
      end, desc = "Summary" },

    {"<leader>to",
      function()
        vim.cmd([[wa]])
        require("neotest").output.open({ enter = true })
      end, desc = "Output" },
})


-- Search and replace
wk.add({
  {"<leader>s", group = "+ Search / Replace"},
  { "<leader>so", function() require('spectre').open() end, desc = "Open spectre" },
  { "<leader>sw", function() require('spectre').open_visual({ select_word = true }) end, desc = "Spectre word under cursor" },
  { "<leader>sf", function() require('spectre').open_file_search({ select_word = true }) end, desc = "Spectre word under cursor, file" },
})

-- Miscellaneous
wk.add({
  { "<leader>m", group = "+ Misc"},
  { "<leader>mf", group = "+ Folding"},
  { "<leader>mfm",
        function()
          vim.cmd([[
                    set foldmethod=manual
                    set foldexpr=0
                ]])
        end, desc = "Manual" },
  { "<leader>mft",
        function()
          vim.cmd([[
                    set foldmethod=expr
                    set foldexpr=nvim_treesitter#foldexpr()
                ]])
        end, desc = "Treesitter"
  },
  { "<leader>mg",
      function()
        vim.cmd([[wa]])
        vim.cmd([[FloatermNew --height=0.8 --width=0.8 --title=git --wintype=float lazygit]])
      end, desc = "Git"
  },
  { "<leader>mq", "<cmd>wqa<cr>", desc = "Write all and quit" },
  { "<leader>mw", "<cmd>wa<cr>", desc = "Write all" },
  { "<leader>my", function() require("telescope").extensions.yank_history.yank_history({}) end, desc = "Yank history" },
  { "<leader>mr", "<cmd>WinResizerStartResize<cr>", desc = "Resize" },
})
