local is_in_vscode = require("utils").is_in_vscode

---@type LazySpec
return {
    {
        "SmiteshP/nvim-navic",
        opts = {
            highlight = true
        },
        lazy = true,
        cond = not is_in_vscode
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
                "folke/neodev.nvim",
                config = true
            }
        },
        config = require "plugins/configs/lsp",
        cond = not is_in_vscode
    },
    {
        "mrcjkb/rustaceanvim",
        version = "^4",
        ft = "rust",
        cond = not is_in_vscode
    },
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        config = true,
        cond = not is_in_vscode
    },
    {
        "kosayoda/nvim-lightbulb",
        opts = { autocmd = { enabled = true } },
        cond = not is_in_vscode
    },
    {
        "mhartington/formatter.nvim",
        cmd = { "Format", "FormatLock", "FormatWrite", "FormatWriteLock" },
        config = function()
            require("formatter").setup {
                logging = false,
                filetype = {
                    python = {
                        require("formatter.filetypes.python").black
                    },
                    javascript = {
                        require("formatter.filetypes.typescript").prettier
                    },
                    typescript = {
                        require("formatter.filetypes.typescript").prettier
                    },
                    typescriptreact = {
                        require("formatter.filetypes.typescript").prettier
                    },
                    nix = {
                        require("formatter.filetypes.nix").alejandra
                    },
                    rust = {
                        require("formatter.filetypes.rust").rustfmt
                    }
                },
            }
        end
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        opts = {
            bind = true,
            handler_opts = {
                border = "rounded"
            }
        },
        cond = not is_in_vscode
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        lazy = true
    },
    {
        "DNLHC/glance.nvim",
        event = "VeryLazy",
        keys = {
            { "gD", "<Cmd>Glance definitions<CR>",      desc = "[Glance] Show definitions",      silent = true },
            { "gR", "<Cmd>Glance references<CR>",       desc = "[Glance] Show references",       silent = true },
            { "gY", "<Cmd>Glance type_definitions<CR>", desc = "[Glance] Show type definitions", silent = true },
            { "gM", "<Cmd>Glance implementations<CR>",  desc = "[Glance] Show implementations",  silent = true },
        },
        config = true,
        cond = not is_in_vscode
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
