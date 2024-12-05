return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")

      dap.adapters.netcoredbg = {
        type = "executable",
        command = "/users/tmadsen/.cache/netcoredbg/netcoredbg",
        args = { "--interpreter=vscode" },
      }

      require("dap.ext.vscode").load_launchjs(nil, {
        cs = { "netcoredbg" },
      })

      vim.keymap.set("n", "<F5>", function()
        require("dap").continue()
      end)
      vim.keymap.set("n", "<F10>", function()
        require("dap").step_over()
      end) -- F10 for step over
      vim.keymap.set("n", "<F11>", function()
        require("dap").step_into()
      end)
      vim.keymap.set("n", "<F12>", function()
        require("dap").step_out()
      end)
    end,
  },
  {
    -- Disable this plugin. It will cause Mason to install a netcoredbg version that is different from the one I have installed.
    -- than the one we want. And that will produce a silly extra option when launching an app in debug ("NetCoreDbg: Launch").
    "jay-babu/mason-nvim-dap.nvim",
    enabled = false,
  },
}
