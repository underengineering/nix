return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        {
            "HiPhish/rainbow-delimiters.nvim",
            branch = "use-children",
            config = require "plugins.configs.rainbow-delimiters"
        },
        "windwp/nvim-ts-autotag"
    },
    config = require "plugins.configs.treesitter",
}
