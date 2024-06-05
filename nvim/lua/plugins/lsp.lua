return {
  {
    -- LSP Stuff
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' }, -- Required
      -- LSP Server installs
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },

      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "tamago324/cmp-zsh" },
    },
    config = function()
      require('config.lsp').post()
    end
  },
  {
    -- Make
    'tpope/vim-dispatch',
    'datamadsen/vim-compiler-plugin-for-dotnet'
  },
  {
    "nvim-neotest/neotest",
    -- keys = { "<leader>n" },
    config = function()
      require("config.neotest").post()
    end,
    dependencies = {
      { "andythigpen/nvim-coverage" },
      { "Issafalcon/neotest-dotnet" },
      { "nvim-neotest/neotest-python" },
      { "nvim-neotest/neotest-plenary" },
      { "rouge8/neotest-rust" },
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    }
  },
  -- Eye candy for nvim-lsp progress
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    opts = {
      text = {
        spinner = "dots"
      }
    }
  },
  { "onsails/lspkind-nvim" },
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = { "L3MON4D3/LuaSnip" }
  },
  {
    "folke/neodev.nvim",
    opts = {},
  },

  -- Goto definition in 3rd party code.
  { "Hoffs/omnisharp-extended-lsp.nvim" },

  -- Code breadcrumbs
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig"
  },

  -- Code outline
  {
    'stevearc/aerial.nvim',
    opts = {}
  },

  -- Code action menu
  { "weilbith/nvim-code-action-menu" },

  -- {
  --   'nvimdev/lspsaga.nvim',
  --   config = function()
  --       require('lspsaga').setup({})
  --   end,
  --   dependencies = {
  --       'nvim-treesitter/nvim-treesitter', -- optional
  --       'nvim-tree/nvim-web-devicons'     -- optional
  --   }
  -- }
}
