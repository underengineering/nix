return {
    "akinsho/bufferline.nvim",
    tag = "v4.2.0",
    event = "BufReadPre",
    dependencies = {
        "kyazdani42/nvim-web-devicons"
    },
    opts = require "plugins.configs.bufferline",
}
