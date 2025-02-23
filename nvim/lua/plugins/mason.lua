return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- Remove csharpier from the ensure_installed list
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "csharpier"
      end, opts.ensure_installed)
    end,
  },
}
