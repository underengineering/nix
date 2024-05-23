local is_in_vscode = require("utils").is_in_vscode

---@type LazySpec
return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "lukas-reineke/cmp-under-comparator",
            "saadparwaiz1/cmp_luasnip"
        },
        config = require "plugins.configs.cmp",
        cond = not is_in_vscode
    },
    {
        "nvim-treesitter/nvim-treesitter",
        events = { "BufEnter", "VeryLazy" },
        dependencies = {
            {
                "HiPhish/rainbow-delimiters.nvim",
                config = require "plugins.configs.rainbow-delimiters"
            },
        },
        config = require "plugins.configs.treesitter",
        cond = not is_in_vscode
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "VeryLazy",
        cond = not is_in_vscode
    },
    {
        "windwp/nvim-ts-autotag",
        event = "VeryLazy",
        config = true
    },
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = true
    },
    {
        "nacro90/numb.nvim",
        event = "BufReadPost",
        config = true
    },
    {
        "L3MON4D3/LuaSnip",
        event = "VeryLazy",
        config = require "plugins/configs/luasnip",
        cond = not is_in_vscode
    },
    {
        "windwp/nvim-autopairs",
        event = "VeryLazy",
        opts = {
            disable_filetype = { "TelescopePrompt" },
        },
        cond = not is_in_vscode
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        config = true
    },
    {
        "echasnovski/mini.nvim",
        keys = {
            { "<Leader>b", function() MiniFiles.open() end, desc = "Open file manager", silent = true }
        },
        config = function() require "plugins.configs.mini" end,
        lazy = false
    },
    {
        "rmagatti/auto-session",
        dependencies = {
            "nvim-telescope/telescope.nvim"
        },
        keys = {
            {
                "<Leader>ts",
                function()
                    require("auto-session.session-lens").search_session()
                end,
                desc = "Lens sessions"
            }
        },
        opts = {
            log_level = "error",
            auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
            auto_restore_enabled = true,
            pre_save_cmds = { "Neotree close" }
        },
        cond = not is_in_vscode,
        lazy = false
    },
    {
        "kwkarlwang/bufresize.nvim",
        event = "VeryLazy",
        config = true,
        cond = not is_in_vscode
    },
    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        config = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_open_ip = "127.0.0.1"
            vim.g.mkdp_port = "8001"
        end,
        build = "cd app && yarn install",
        cond = not is_in_vscode,
        lazy = true
    },
    {
        "Vigemus/iron.nvim",
        cmd = { "IronAttach", "IronRepl", "IronReplHere", "IronRestart", "IronFocus", "IronHide", "IronWatch" },
        config = function()
            local iron = require("iron.core")
            iron.setup {
                config = {
                    repl_definition = {
                        python = { command = "python" },
                        javascript = { command = "node" }
                    },
                    repl_open_cmd = require("iron.view").bottom(40),
                    ignore_blank_lines = true,
                },
                keymaps = {
                    visual_send = "<Leader>sc",
                    send_until_cursor = "<Leader>su"
                }
            }
        end,
        keys = {
            { "<Leader>rs", "<Cmd>IronRepl<CR>",    desc = "[Iron] Start Iron" },
            { "<Leader>rr", "<Cmd>IronRestart<CR>", desc = "[Iron] Restart Iron" },
            { "<Leader>rf", "<Cmd>IronFocus<CR>",   desc = "[Iron] Focus Iron" },
        },
        cond = not is_in_vscode
    },

    {
        "Exafunction/codeium.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        opts = {
            enable_chat = true,
            tools = { language_server = vim.fn.exepath("codeium_language_server") }
        },
        cond = not is_in_vscode
    }
}
