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

        "typescript",
        "javascript",
        "html",
        "css",
        "svelte",
    }
end

return function()
    local rainbow_delimiters = require("rainbow-delimiters")
    vim.g.rainbow_delimiters = {
        strategy = {
            [""] = function()
                if vim.api.nvim_buf_line_count(0) > 10000 then return nil end
                return rainbow_delimiters.strategy["global"]
            end,
        },
        query = {
            [""] = "rainbow-delimiters",
        }
    }

    require("nvim-treesitter.configs").setup {
        ensure_installed = ensure_installed,
        ignore_install = {},
        auto_install = false,
        sync_install = is_headless,
        highlight = { enable = true },
        autotag = { enable = true },
        modules = {}
    }
end
