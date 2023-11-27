return {
  'mfussenegger/nvim-dap',
  lazy = true,
  config = function()
    local dap = require('dap')

    dap.adapters.coreclr = {
      type = 'executable',
      command = '/Users/tmadsen/.cache/netcoredbg/netcoredbg',
      args = { '--interpreter=vscode' }
    }

    dap.adapters.netcoredbg = {
      type = 'executable',
      command = '/Users/tmadsen/.cache/netcoredbg/netcoredbg',
      args = { '--interpreter=vscode' }
    }

    dap.configurations.cs = {
      type = "coreclr",
      name = "launch - netcoredbg",
      request = "launch",
      program = function()
        return vim.fn.input('Hygge :) Path to dll ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
      end,
    }
  end,
  dependencies = {
    'rcarriga/nvim-dap-ui',
    "nvim-telescope/telescope-dap.nvim",
  }
}
