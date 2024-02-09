return {
  {
    'ellisonleao/gruvbox.nvim',
    event = "VeryLazy"
  },
  {
    'navarasu/onedark.nvim',
    lazy = true
  },
  {
    'folke/tokyonight.nvim',
    event = "VeryLazy"
  },
  {
    'rose-pine/neovim',
    event = "VeryLazy"
  },
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme nightfox]])
    end
  }
}
