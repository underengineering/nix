return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
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
}
