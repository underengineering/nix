local is_headless = #vim.api.nvim_list_uis() == 0
local ensure_installed = {}
if true then
    ensure_installed = {
        "vim",
        "regex",
        "bash",
        "markdown",
        "markdown_inline",

        "toml",
        "json",
        "dockerfile",

        "c",
        "cpp",
        "rust",

        "lua",
        "python",

        "tsx",
        "typescript",
        "javascript",
        "html",
        "css",
        "svelte",
    }
end

return function()
    require("nvim-treesitter.configs").setup {
        ensure_installed = ensure_installed,
        ignore_install = {},
        auto_install = false,
        sync_install = is_headless,
        highlight = { enable = true },
        autotag = { enable = true },
        textobjects = {
            select = {
                enable = true,

                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["af"] = { query = "@function.outer", desc = "Select outside function" },
                    ["if"] = { query = "@function.inner", desc = "Select inside function" },
                    ["ac"] = { query = "@class.outer", desc = "Select outside class" },
                    ["ic"] = { query = "@class.inner", desc = "Select inside class" },
                    ["ia"] = { query = "@parameter.outer", desc = "Select outside parameter" },
                    ["aa"] = { query = "@parameter.inner", desc = "Select inside parameter" },
                    ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                },
                -- You can choose the select mode (default is charwise 'v')
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * method: eg 'v' or 'o'
                -- and should return the mode ('v', 'V', or '<c-v>') or a table
                -- mapping query_strings to modes.
                selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V',  -- linewise
                    ['@class.outer'] = '<c-v>', -- blockwise
                },
                -- If you set this to `true` (default is `false`) then any textobject is
                -- extended to include preceding or succeeding whitespace. Succeeding
                -- whitespace has priority in order to act similarly to eg the built-in
                -- `ap`.
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * selection_mode: eg 'v'
                -- and should return true of false
                include_surrounding_whitespace = true,
            }
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>",
                scope_incremental = "<CR>",
                node_incremental = "<TAB>",
                node_decremental = "<S-TAB>",
            },
        },
        modules = {}
    }
end
