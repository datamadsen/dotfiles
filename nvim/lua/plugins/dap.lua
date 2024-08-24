return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")

      dap.adapters.netcoredbg = {
        type = "executable",
        command = "/Users/tmadsen/.cache/netcoredbg/netcoredbg",
        args = { "--interpreter=vscode" },
      }

      -- We set an empty configuration for cs, because we are using launch.json files to
      -- configure the ways we want to debug our applications. If we do not set an empty
      -- configuration, we will get this default:
      -- https://github.com/LazyVim/LazyVim/blob/12818a6cb499456f4903c5d8e68af43753ebc869/lua/lazyvim/plugins/extras/lang/omnisharp.lua#L85
      dap.configurations.cs = nil
    end,
  },
  {
    -- Disable this plugin. It will cause Mason to install a netcoredbg version that is different from the one I have installed.
    -- than the one we want. And that will produce a silly extra option when launching an app in debug ("NetCoreDbg: Launch").
    "jay-babu/mason-nvim-dap.nvim",
    enabled = false,
  },
}
