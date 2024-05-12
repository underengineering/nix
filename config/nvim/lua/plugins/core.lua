local is_in_vscode = require("utils").is_in_vscode
local not_in_vscode = function() return not is_in_vscode end

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
            "saadparwaiz1/cmp_luasnip",
            {
                "tzachar/cmp-tabnine",
                cond = function() -- Fix ugly errors when tabnine is not downloaded
                    local tabnine_path = vim.fn.expand("HOME")
                    local tabnine_conf = "/.config/TabNine/tabnine_config.json"
                    return false and vim.fn.filereadable(tabnine_path .. tabnine_conf)
                end,
                build = "./install.sh"
            },
        },
        config = function() require "plugins.configs.cmp" end,
        cond = not_in_vscode
    },
    {
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
            config = require "plugins.configs.treesitter",
            cond = not_in_vscode
        }
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
    -- Performance issues
    -- {
    --     "winston0410/range-highlight.nvim",
    --     dependencies = {
    --         "winston0410/cmd-parser.nvim"
    --     },
    --     config = true
    -- },
    {
        "L3MON4D3/LuaSnip",
        event = "VeryLazy",
        config = require "plugins/configs/luasnip",
        cond = not_in_vscode
    },
    {
        "windwp/nvim-autopairs",
        event = "VeryLazy",
        opts = {
            disable_filetype = { "TelescopePrompt" },
        },
        cond = not_in_vscode
    },
    -- {
    --     "ggandor/leap.nvim",
    --     event = "VeryLazy",
    --     config = require "plugins.configs.leap"
    -- },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        config = true,
        keys = {
            {
                "s",
                mode = { "n", "x", "o" },
                function()
                    require("flash").jump()
                end,
                desc = "Flash"
            }
        }
    },
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = true
    },
    {
        "rmagatti/auto-session",
        dependencies = {
            "nvim-telescope/telescope.nvim"
        },
        opts = {
            log_level = "error",
            auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
            auto_restore_enabled = true,
            pre_save_cmds = { "Neotree close" }
        },
        cond = not_in_vscode
    },
    {
        "linux-cultist/venv-selector.nvim",
        cmd = { "VenvSelect", "VenvSelectCached" },
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-telescope/telescope.nvim"
        },
        opts = {
            search = false,
            search_workspace = true,
            name = { "venv", "env" }
        },
        cond = not_in_vscode
    },
    {
        "kwkarlwang/bufresize.nvim",
        event = "VeryLazy",
        config = true,
        cond = not_in_vscode
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
        cond = not_in_vscode,
        lazy = true
    },
    {
        "Vigemus/iron.nvim",
        config = function()
            local iron = require("iron.core")
            iron.setup {
                config = {
                    repl_definition = {
                        python = { command = "python" },
                        javascript = { command = "node" }
                    },
                    repl_open_cmd = require('iron.view').bottom(40),
                    ignore_blank_lines = true,
                },
                keymaps = {
                    visual_send = "<Leader>sc",
                    send_until_cursor = "<Leader>su"
                }
            }
        end,
        cmd = { "IronAttach", "IronRepl", "IronReplHere", "IronRestart", "IronFocus", "IronHide", "IronWatch" },
        cond = not_in_vscode
    },

    {
        "Exafunction/codeium.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("codeium").setup({
                enable_chat = true,
                tools = { language_server = vim.fn.exepath("codeium_language_server") }
            })
        end,
        cond = not_in_vscode
    }
}
