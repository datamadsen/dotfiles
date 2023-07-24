return {
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
    },
    cmdline = {
        view = "cmdline",
    },
    messages = {
        enabled = false
    },
    signature = {
      enabled = false
    },
    routes = {
        {
            filter = {
                event = "msg_show",
                kind = "search_count",
            },
            opts = { skip = true },
        },
    },
}
