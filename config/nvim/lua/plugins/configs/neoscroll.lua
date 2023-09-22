return function()
    require("neoscroll").setup {
        easing_function = "quartic"
    }

    local mappings = {}
    mappings["<C-j>"] = { "scroll", { "vim.wo.scroll", "true", 200 } }
    mappings["<C-k>"] = { "scroll", { "-vim.wo.scroll", "true", 200 } }

    require("neoscroll.config").set_mappings(mappings)
end
