return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            {
                "HiPhish/rainbow-delimiters.nvim",
                config = require "plugins.configs.rainbow-delimiters"
            },
            "windwp/nvim-ts-autotag"
        },
        config = require "plugins.configs.treesitter"
    }
}
