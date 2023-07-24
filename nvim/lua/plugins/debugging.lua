return {
    {
        'mfussenegger/nvim-dap',
        lazy = true,
        config = require("config.dap"),
        dependencies = {
            {
                'rcarriga/nvim-dap-ui',
                opts = require("config.dap-ui")
            },
            {
                "nvim-telescope/telescope-dap.nvim",
                config = function()
                    require('telescope').load_extension('dap')
                end
            }
        }
    }
}
