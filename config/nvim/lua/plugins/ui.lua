---@type LazySpec
return {
    {
        "rachartier/tiny-devicons-auto-colors.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require("tiny-devicons-auto-colors").setup({
                colors = require("gruvbox").palette
            })
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "debugloop/telescope-undo.nvim",
            "Marskey/telescope-sg"
        },
        keys = {
            { "<Leader>tb", "<Cmd>Telescope buffers<CR>",     desc = "Find a buffer",                 silent = true },
            { "<Leader>tf", "<Cmd>Telescope find_files<CR>",  desc = "Find a file",                   silent = true },
            { "<Leader>tg", "<Cmd>Telescope live_grep<CR>",   desc = "Find in files",                 silent = true },
            { "<Leader>ta", "<Cmd>Telescope ast_grep<CR>",    desc = "Find in files using ast-grep",  silent = true },
            { "<Leader>td", "<Cmd>Telescope definitions<CR>", desc = "Find a definition",             silent = true },
            { "<Leader>tu", "<Cmd>Telescope undo<CR>",        desc = "List undo history",             silent = true },
            { "<Leader>tr", "<Cmd>Telescope resume<CR>",      desc = "Resumes last telescope search", silent = true },
            {
                "<Leader>t/",
                function()
                    local themes = require("telescope.themes")
                    require("telescope.builtin").current_buffer_fuzzy_find(themes.get_dropdown {
                        winblend = 10,
                        previewer = false,
                    })
                end,
                desc = "Find in current buffer",
                silent = true
            }
        },
        config = require "plugins/configs/telescope",
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        opts = {}
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
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        config = true,
    },
    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        keys = {
            { "<Leader>g" },
            { "<Leader>lp", "<Cmd>TroubleToggle<CR>", desc = "[Trouble] Toggle diagnostic view" },
        },
        config = require "plugins/configs/toggleterm",
    },
    {
        "petertriho/nvim-scrollbar",
        event = "BufReadPost",
        opts = {
            show_in_active_only = false,
            hide_if_all_visible = true,
            excluded_filetypes = { "prompt", "TelescopePrompt", "noice", "notify" },
            handle = {
                color = "BufferLineTabSelected"
            },
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
        keys = {
            "<Leader>cp",
            "<Cmd>CccPick<CR>",
            desc = "Pick color"
        },
        opts = {
            highlighter = {
                auto_enable = true,
                lsp = true,
            }
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufEnter",
        config = require "plugins/configs/indent-blankline",
    },
    {
        "lukas-reineke/virt-column.nvim",
        event = "BufEnter",
        config = true,
    },
    {
        "akinsho/bufferline.nvim",
        event        = "VeryLazy",
        dependencies = {
            "kyazdani42/nvim-web-devicons"
        },
        keys         = {
            { "<C-,>",      ":BufferLineCyclePrev<CR>", desc = "Prev buffer",              silent = true },
            { "<C-.>",      ":BufferLineCycleNext<CR>", desc = "Next buffer",              silent = true },
            { "<C-;>",      ":BufferLineMovePrev<CR>",  desc = "Move buffer to the left",  silent = true },
            { "<C-'>",      ":BufferLineMoveNext<CR>",  desc = "Move buffer to the right", silent = true },
            { "<Leader>po", ":BufferLinePick<CR>",      desc = "Pick buffer to open",      silent = true },
            { "<Leader>pc", ":BufferLinePickClose<CR>", desc = "Pick buffer to close",     silent = true },
        },
        opts         = {
            options = {
                separator_style = "thin",
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "File Explorer",
                        highlight = "Directory",
                        separator = true
                    }
                }
            },
        },
    }
}
