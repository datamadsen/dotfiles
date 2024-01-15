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
      {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
          return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/dmm.webapi/bin/Debug/net8.0/dmm.webapi.dll', 'file')
          -- return vim.fn.input('Hygge :) Path to dll ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
        -- env = {
        --   ASPNETCORE_ENVIRONMENT = function()
        --     return "localhost"
        --   end,
        --   ASPNETCORE_URLS = function ()
        --     return "https://localhost:5001"
        --   end
        -- },
        cwd = function () -- This is important in order to load the appsettings files correctly.
          return vim.fn.getcwd() .. '/dmm.webapi/'
        end
      }
    }
  end,
  dependencies = {
    'rcarriga/nvim-dap-ui',
    "nvim-telescope/telescope-dap.nvim",
  }
}
