return {
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      opts.winopts = {
        height = 0.9,
        width = 0.9,
        preview = {
          layout = "vertical",
          vertical = "down:75%",
        },
      }
      return opts
    end,
  },
}
