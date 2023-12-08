---@type LazySpec
return {

    {
        "ellisonleao/gruvbox.nvim",
        enabled = true,
        priority = 10000,
        lazy = false,
        config = function(_, opts)
            require("gruvbox").setup(opts)
            vim.cmd "colorscheme gruvbox"
        end,
        opts = {
            contrast = "",
            italic = {
                strings = false,
                comments = false,
                operators = false,
                folds = false
            }
        }
    },
    --[[ {
        "rebelot/kanagawa.nvim",
        priority = 10000,
        lazy = false,
        config = function(_, opts)
            require("kanagawa").setup(opts)
            vim.cmd "colorscheme kanagawa-dragon"
        end,
        opts = {
            theme = "wave"
        }
    } ]]
}
