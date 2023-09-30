return function()
    local rainbow_hi_groups = require("plugins.configs.lib.highlight").rainbow_hi_groups
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        for _, group in ipairs(rainbow_hi_groups) do
            vim.api.nvim_set_hl(0, "Ibl" .. group.name, {
                fg = group.fg,
            })
        end
    end)

    local highlight = {}
    for idx, group in ipairs(rainbow_hi_groups) do
        highlight[idx] = "Ibl" .. group.name
    end

    require("ibl").setup {
        show_current_context = true,
        show_current_context_start = true,
        scope = { enabled = true, highlight = highlight }
    }
end
