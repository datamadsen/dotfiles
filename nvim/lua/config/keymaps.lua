-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "Open CodeCompanion Chat" })

vim.keymap.set("n", "<leader>gw", "<cmd>wa | !git wip<cr>", { desc = "WIP commit" })
