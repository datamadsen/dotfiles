return {
  {
    'ellisonleao/gruvbox.nvim',
    event = "VeryLazy"
  },
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme onedark]])
    end
  },
  {
    'folke/tokyonight.nvim',
    event = "VeryLazy"
  },
  {
    'rose-pine/neovim',
    event = "VeryLazy"
  }
}
