---@type LazySpec
return {
    {
        "SmiteshP/nvim-navic",
        opts = {
            highlight = true
        },
        lazy = true
    },
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
            "SmiteshP/nvim-navic",
            "b0o/schemastore.nvim",
            {
                "simrat39/rust-tools.nvim",
                dependencies = {
                    "nvim-lua/plenary.nvim",
                    "mfussenegger/nvim-dap"
                }
            },
            {
                "folke/neodev.nvim",
                config = true
            }
        },
        config = function() require "plugins/configs/lsp" end,
    },
    {
        "kosayoda/nvim-lightbulb",
        opts = { autocmd = { enabled = true } },
    },
    {
        "mhartington/formatter.nvim",
        cmd = { "Format", "FormatLock", "FormatWrite", "FormatWriteLock" },
        config = function() require "plugins/configs/formatter" end
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        lazy = true
    },
    {
        "DNLHC/glance.nvim",
        event = "VeryLazy",
        config = true,
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble", "TroubleClose", "TroubleRefresh", "TroubleToggle" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = true,
    },
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        config = true,
    },
}
