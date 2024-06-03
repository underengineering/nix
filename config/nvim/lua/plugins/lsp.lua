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
            "SmiteshP/nvim-navic",
            "b0o/schemastore.nvim",
        },
        config = require "plugins/configs/lsp",
        cond = not is_in_vscode
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            enabled = true,
        },
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
        opts = {},
        cond = not is_in_vscode
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo", "AutoFormatEnable", "AutoFormatDisable" },
        config = function()
            local auto_format = true
            vim.api.nvim_create_user_command("AutoFormatEnable", function()
                auto_format = true
            end, {})

            vim.api.nvim_create_user_command("AutoFormatDisable", function()
                auto_format = false
            end, {})


            require("conform").setup {
                formatters_by_ft = {
                    python = { "ruff_organize_imports", "ruff-lsp" },
                    javascript = { { "prettierd", "prettier" } },
                    typescript = { { "prettierd", "prettier" } },
                    javascriptreact = { { "prettierd", "prettier" } },
                    typescriptreact = { { "prettierd", "prettier" } },
                    nix = { "alejandra" },
                    rust = { "rustfmt" },
                    lua = {}
                },
                format_on_save = function()
                    ---@diagnostic disable-next-line: return-type-mismatch
                    if not auto_format then return nil end
                    return { timeout_ms = 2000, lsp_fallback = true }
                end
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
        "DNLHC/glance.nvim",
        event = "VeryLazy",
        keys = {
            { "gD", "<Cmd>Glance definitions<CR>",      desc = "[Glance] Show definitions",      silent = true },
            { "gR", "<Cmd>Glance references<CR>",       desc = "[Glance] Show references",       silent = true },
            { "gY", "<Cmd>Glance type_definitions<CR>", desc = "[Glance] Show type definitions", silent = true },
            { "gM", "<Cmd>Glance implementations<CR>",  desc = "[Glance] Show implementations",  silent = true },
        },
        opts = {},
        cond = not is_in_vscode
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble", "TroubleClose", "TroubleRefresh", "TroubleToggle" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        opts = {},
    },
}
