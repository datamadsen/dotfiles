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

      vim.keymap.set("n", "<F5>", require("dap").continue, { desc = "Continue" })
      vim.keymap.set("n", "<F10>", require("dap").step_over, { desc = "Step over current line" })
      vim.keymap.set("n", "<F11>", require("dap").step_into, { desc = "Step into current function" })
      vim.keymap.set("n", "<F12>", require("dap").step_out, { desc = "Step out of current function" })
      vim.keymap.set("n", "<S-F5>", function()
        require("dap").terminate()
        require("dapui").close()
      end, { desc = "Stop debugging and close UI" })
    end,
  },
  {
    -- Disable this plugin. It will cause Mason to install a netcoredbg version that is different from the one I have installed.
    -- than the one we want. And that will produce a silly extra option when launching an app in debug ("NetCoreDbg: Launch").
    "jay-babu/mason-nvim-dap.nvim",
    enabled = false,
  },
}
