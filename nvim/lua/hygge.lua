local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local lspkind = require("lspkind")
-- .init({
--     mode = "symbol_text",
--     preset = "codicons"
-- });

local colors = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "colors",
        finder = finders.new_table({
            results = {
                "red", "green", "blue", lspkind.symbolic("Module", {
                mode = "symbol_text",
                preset = "codicons"
            })
            }
        }),
        sorter = conf.generic_sorter(opts)
    }):find()
end

local dynamic_colors = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "colors",
        finder = finders.new_dynamic({
            fn = function()
            }
        }),
        sorter = conf.generic_sorter(opts)
    }):find()
end

dynamic_colors()
