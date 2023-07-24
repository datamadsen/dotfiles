-- Basic config
vim.diagnostic.config({
    virtual_text = false,
    underline = false,
})

local shown_for_lnum = -1
function NotifyDiagnostics(opts, bufnr, line_nr)
    bufnr = bufnr or 0
    line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
    opts = opts or { ['lnum'] = line_nr }

    local line_diagnostics = vim.diagnostic.get(bufnr, opts)
    if vim.tbl_isempty(line_diagnostics) then return end

    local diagnostic_message = ""
    local diagnostic_severity;
    for i, diagnostic in ipairs(line_diagnostics) do
        diagnostic_message = diagnostic_message .. string.format("%s", diagnostic.message or "")
        diagnostic_severity = diagnostic.severity
        if i ~= #line_diagnostics then
            diagnostic_message = diagnostic_message .. "\n\n"
        end
    end

    local levels =
    {
        [vim.diagnostic.severity.ERROR] = "error",
        [vim.diagnostic.severity.WARN] = "warning",
        [vim.diagnostic.severity.INFO] = "info",
        [vim.diagnostic.severity.HINT] = "hint",
    }

    if shown_for_lnum ~= line_nr then
        vim.notify(diagnostic_message, levels[diagnostic_severity],
            {
                title = "Diagnostics",
                hide_from_history = true,
                timeout = 30000,
                animate = false,
                on_open = function(win)
                    shown_for_lnum = line_nr
                    local buf = vim.api.nvim_win_get_buf(win)
                    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

                    -- Close notification when cursor is moved.
                    local group = vim.api.nvim_create_augroup("DiagnosticsOpen", { clear = true })
                    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
                        pattern = { "*" },
                        callback = function()
                            local new_line_nr = (vim.api.nvim_win_get_cursor(0)[1] - 1)
                            if shown_for_lnum ~= new_line_nr then
                                shown_for_lnum = -1
                                pcall(vim.api.nvim_win_close, win, true)
                            end
                        end,
                        group = group
                    })
                    vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
                        pattern = { "*" },
                        callback = function()
                            shown_for_lnum = -1
                            pcall(vim.api.nvim_win_close, win, true)
                        end,
                        group = group
                    })
                end
            })
    end
end

vim.cmd [[ autocmd! CursorHold * lua NotifyDiagnostics() ]]

-- Change signs in sign column
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
