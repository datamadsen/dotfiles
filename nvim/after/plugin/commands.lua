-- Setup commander

local commander = require("commander")
local commands = {
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
