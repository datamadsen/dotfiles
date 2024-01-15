return {
  {
    "tpope/vim-surround",
    init = function()
      vim.g["surround_no_mappings"] = 1
      -- Just the defaults copied here.
      vim.keymap.set("n", "ds", "<Plug>Dsurround")
      vim.keymap.set("n", "cs", "<Plug>Csurround")
      vim.keymap.set("n", "cS", "<Plug>CSurround")
      vim.keymap.set("n", "ys", "<Plug>Ysurround")
      vim.keymap.set("n", "yS", "<Plug>YSurround")
      vim.keymap.set("n", "yss", "<Plug>Yssurround")
      vim.keymap.set("n", "ySs", "<Plug>YSsurround")
      vim.keymap.set("n", "ySS", "<Plug>YSsurround")

      -- The leap conflicting ones. Note that `<Plug>(leap-cross-window)`
      -- _does_ work in Visual mode, if jumping to the same buffer,
      -- so in theory, `gs` could be useful for Leap too...
      -- vim.keymap.set("x", "gs", "<Plug>VSurround")
      -- vim.keymap.set("x", "gS", "<Plug>VgSurround")
    end

  },
  { 'simeji/winresizer' },
  { 'kdheepak/lazygit.nvim' },
  { 'tpope/vim-fugitive' },
  { 'lewis6991/gitsigns.nvim',   opts = {} },
  { "windwp/nvim-autopairs",     opts = {} },
  { "nvim-pack/nvim-spectre" },
  { 'numToStr/Comment.nvim',     opts = {} },
  { 'folke/which-key.nvim',      opts = {} },
  { 'petertriho/nvim-scrollbar', opts = {} },
  { 'mbbill/undotree' },
}
