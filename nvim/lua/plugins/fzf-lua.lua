local function action_noop(_, opts)
  local o = vim.tbl_deep_extend("keep", { resume = true }, opts.__call_opts)
  opts.__call_fn(o)
end

return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    opts = vim.tbl_deep_extend("force", opts, {
      actions = {
        files = {
          true,
          ["ctrl-g"] = { action_noop },
        },
      },
      winopts = {
        height = 0.9,
        width = 0.9,
        preview = {
          layout = "vertical",
          vertical = "down:75%",
        },
      },
    })
    return opts
  end,
}
