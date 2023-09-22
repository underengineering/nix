return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        { "HiPhish/rainbow-delimiters.nvim", branch = "use-children" },
        "windwp/nvim-ts-autotag"
    },
    config = require "plugins.configs.treesitter",
}
