vim.o.textwidth = 80
-- Leader 1 for _italic_
vim.cmd([[nnoremap <Leader>1 ciw_<C-r>"_<Esc>]])
vim.cmd([[vnoremap <Leader>1 c_<C-r>"_<Esc>]])
-- Leader 2 for *bold*
vim.cmd([[nnoremap <Leader>2 ciw*<C-r>"*<Esc>]])
vim.cmd([[vnoremap <Leader>2 c*<C-r>"*<Esc>]])
-- Create a Markdown-link structure for the current word or visual selection with
-- leader 3. Paste in the URL later.
vim.cmd([[nnoremap <Leader>3 ciw[<C-r>"]()<Esc>]])
vim.cmd([[vnoremap <Leader>3 c[<C-r>"]()<Esc>]])
-- Use leader 4 to create the same structure as with leader 3,
-- *and* insert the current system clipboard as an URL.
vim.cmd([[nnoremap <Leader>4 ciw[<C-r>"](<Esc>"*pa)<Esc>]])
vim.cmd([[vnoremap <Leader>4 c[<C-r>"](<Esc>"*pa)<Esc>]])
-- Insert current date and time
vim.cmd([[nmap <Leader>5 i<C-R>=strftime("%Y-%m-%d %I:%M %p")<CR><Esc>]])
-- Insert current date and time
vim.cmd([[nmap <Leader>5 i<C-R>=strftime("%Y-%m-%d %I:%M %p")<CR><Esc>]])
