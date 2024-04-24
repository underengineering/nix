---@type LazySpec
return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "debugloop/telescope-undo.nvim",
            "Marskey/telescope-sg"
        },
        config = require "plugins/configs/telescope",
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        dependencies = {
            -- "stevearc/oil.nvim",
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = require "plugins.configs.neo-tree",
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim",
        },
        config = true
    },
    {
        "rebelot/heirline.nvim",
        config = require "plugins/configs/heirline",
        dependencies = {
            "VonHeikemen/lsp-zero.nvim", -- For icons
            "kyazdani42/nvim-web-devicons",
            "SmiteshP/nvim-navic",
            "lewis6991/gitsigns.nvim",
        },
    },
    {
        "goolord/alpha-nvim",
        config = require "plugins/configs/alpha"
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            disable = { filetypes = { "TelescopePrompt" } },
        },
    },
    {
        "folke/noice.nvim",
        -- event = "VeryLazy",
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
    },
    {
        "folke/todo-comments.nvim",
        event = "BufReadPost",
        config = true,
    },
    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        keys = {
            { "<Leader>g" }
        },
        config = function() require "plugins/configs/toggleterm" end,
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
    },
    {
        "lewis6991/gitsigns.nvim",
        cmd = "Gitsigns",
        event = "BufReadPre",
        config = true,
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
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        config = require "plugins/configs/indent-blankline",
    },
    {
        "lukas-reineke/virt-column.nvim",
        event = "BufEnter",
        config = true,
    },
    {
        "akinsho/bufferline.nvim",
        tag = "v4.5.2",
        event = "BufReadPre",
        dependencies = {
            "kyazdani42/nvim-web-devicons"
        },
        opts = require "plugins.configs.bufferline",
    }
}
