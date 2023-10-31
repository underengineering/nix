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

        "jsx",
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
        modules = {}
    }
end
