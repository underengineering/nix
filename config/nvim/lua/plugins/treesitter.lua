return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        {
            "HiPhish/rainbow-delimiters.nvim",
            config = require "plugins.configs.rainbow-delimiters"
        },
        "windwp/nvim-ts-autotag"
    },
    config = require "plugins.configs.treesitter",
}
