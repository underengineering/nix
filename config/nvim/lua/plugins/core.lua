local is_in_vscode = require("utils").is_in_vscode
local not_in_vscode = function() return not is_in_vscode end

return {
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
        "rebelot/heirline.nvim",
        config = require "plugins/configs/heirline",
        dependencies = {
            "VonHeikemen/lsp-zero.nvim", -- For icons
            "kyazdani42/nvim-web-devicons",
            "SmiteshP/nvim-navic",
            "lewis6991/gitsigns.nvim",
        },
        cond = not_in_vscode
    },
    {
        "goolord/alpha-nvim",
        config = require "plugins/configs/alpha"
    },
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        config = true,
        cond = not_in_vscode
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble", "TroubleClose", "TroubleRefresh", "TroubleToggle" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = true,
        cond = not_in_vscode
    },
    {
        "L3MON4D3/LuaSnip",
        event = "VeryLazy",
        dependencies = {
            "rafamadriz/friendly-snippets"
        },
        config = require "plugins/configs/luasnip",
        cond = not_in_vscode
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            disable = { filetypes = { "TelescopePrompt" } },
        },
        cond = not_in_vscode
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify"
        },
        opts = {
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                signature = { enabled = false },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true,
            }
        },
        cond = not_in_vscode
    },
    {
        "folke/todo-comments.nvim",
        event = "BufReadPost",
        config = true,
        cond = not_in_vscode
    },
    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        keys = {
            { "<Leader>g" }
        },
        config = function() require "plugins/configs/toggleterm" end,
        cond = not_in_vscode
    },
    {
        "petertriho/nvim-scrollbar",
        event = "BufReadPost",
        opts = {
            show_in_active_only = false,
            hide_if_all_visible = true,
            handle = {
                color = "BufferLineTabSelected"
            },
            -- marks = {
            --     Search = { color = palette.bright_orange },
            --     Error  = { color = palette.bright_red },
            --     Warn   = { color = palette.bright_yellow },
            --     Info   = { color = palette.bright_blue },
            --     Hint   = { color = palette.bright_aqua },
            --     Misc   = { color = palette.bright_purple },
            -- }
        },
        cond = not_in_vscode
    },
    {
        "karb94/neoscroll.nvim",
        config = require "plugins.configs.neoscroll",
        cond = not_in_vscode
    },
    {
        "windwp/nvim-autopairs",
        event = "VeryLazy",
        opts = {
            disable_filetype = { "TelescopePrompt" },
        }
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
        "lewis6991/gitsigns.nvim",
        cmd = "Gitsigns",
        event = "BufReadPre",
        config = true,
        cond = not_in_vscode
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
        "uga-rosa/ccc.nvim",
        event = "BufReadPost",
        opts = {
            highlighter = {
                auto_enable = true,
                lsp = true,
            }
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
        "lukas-reineke/indent-blankline.nvim",
        config = require "plugins/configs/indent-blankline",
    },
    {
        "lukas-reineke/virt-column.nvim",
        event = "BufEnter",
        config = true,
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
    }
}
