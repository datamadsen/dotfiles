-- Setup commander

local commander = require("commander")
local commands = {
  {
    desc = "Test: Run nearest",
    cmd = function()
      require('neotest').run.run()
    end
  },
  {
    desc = "Test: Debug nearest",
    cmd = function()
      vim.cmd "set number"
      vim.cmd "set rnu"
      vim.o.signcolumn = 'yes'
      require("neotest").run.run({ strategy = "dap", suite = false })
    end
  },
  {
    desc = "Test: Run file",
    cmd = function()
      require("neotest").run.run(vim.fn.expand("%"))
    end
  },
  {
    desc = "Test: Summary",
    cmd = function()
      require('neotest').run.run()
    end
  },
  {
    desc = "Test: Output",
    cmd = function()
      require('neotest').output.open()
    end
  },
  {
    desc = "Toggle line numbers",
    cmd = function()
      vim.cmd "set number!"
      vim.cmd "set rnu!"
      if vim.o.signcolumn == 'no' then
        vim.o.signcolumn = 'yes'
      else
        vim.o.signcolumn = 'no'
      end
    end
  },
  {
    desc = "Git",
    cmd = function()
      vim.cmd ":LazyGit"
    end
  },
  {
    desc = "Diagnostics: file",
    cmd = function()
      require('telescope.builtin').diagnostics({ bufnr = 0 })
    end
  },
  {
    desc = "Folding: Toggle TS/Manual",
    cmd = function()
      local title = "Folding: Toggle TS/Manual"
      -- Toggle between
      if vim.o.foldmethod == 'expr' then
        vim.cmd([[
                    set foldmethod=manual
                    set foldexpr=0
                ]])
        vim.notify("Now Using: Manual folds", "info", { title = title })
      else
        vim.cmd([[
                    set foldmethod=expr
                    set foldexpr=nvim_treesitter#foldexpr()
                ]])
        vim.notify("Now Using: Treesitter folds", "info", { title = title })
      end
    end
  }
}

-- commander.remove(commands)
commander.add(commands, {})
