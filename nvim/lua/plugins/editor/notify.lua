return
{
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  opts = {
    max_height = function()
      return 50
    end,
    max_width = function()
      return 120
    end,
    render = "wrapped-compact",
  }
}
