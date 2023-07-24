return {
  { "tpope/vim-surround" },
  { 'simeji/winresizer' },
  { 'kdheepak/lazygit.nvim' },
  { 'tpope/vim-fugitive' },
  { 'lewis6991/gitsigns.nvim', opts = {} },
  { "windwp/nvim-autopairs",   opts = {} },
  { "nvim-pack/nvim-spectre" },
  { 'numToStr/Comment.nvim',   opts = {} },
  { 'folke/which-key.nvim',    opts = {} },
  { 'mbbill/undotree' },
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      'mortepau/codicons.nvim'
    },
    opts = require('config.neotree')
  },
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = require('config.noice')
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = require("config.indent-blanklines"),
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    opts = require("config.lualine")
  },
  {
    "alexghergh/nvim-tmux-navigation",
    opts = require("config.tmux-navigation")
  },
  {
    "utilyre/barbecue.nvim",     -- winbar
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
  {
    "datamadsen/codescope",
    dir = "~/source/codescope.nvim/",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      'nvim-lua/plenary.nvim',
    }
  }
}
