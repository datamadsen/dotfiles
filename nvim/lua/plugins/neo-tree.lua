return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    auto_expand_width = true,
    window = {
      width = 60,
    },
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.opt_local.number = true
          vim.opt_local.relativenumber = true
        end,
      },
    },
  },
}
