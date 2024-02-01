-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
-- vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.wo.signcolumn = 'yes'
vim.wo.number = true
vim.wo.relativenumber = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Save files before quitting?
vim.o.confirm = true

-- Show yourself
vim.o.cursorline = true

-- Not sure why, but suddenly clipboard tool was tmuxclipboard
-- here we set it explicitly for mac's pbcopy and pbpaste
vim.g.clipboard = {
  name = 'pbcopy and pbpaste',
  copy = {
    ['+'] = { 'pbcopy', '-' },
    ['*'] = { 'pbcopy', '-' },
  },
  paste = {
    ['+'] = { 'pbpaste', '-' },
    ['*'] = { 'pbpaste', '-' },
  },
  cache_enabled = 1
}
