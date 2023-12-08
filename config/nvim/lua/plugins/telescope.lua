---@type LazySpec
return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        "debugloop/telescope-undo.nvim",
        "Marskey/telescope-sg"
    },
    config = require "plugins/configs/telescope",
}
