return function()
    local rainbow_hi_groups = require("plugins.configs.lib.highlight").rainbow_hi_groups
    local function register_hi_groups()
        for _, group in ipairs(rainbow_hi_groups) do
            vim.api.nvim_set_hl(0, "RainbowDelimiter" .. group.name, {
                fg = group.fg,
            })
        end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = register_hi_groups
    })

    register_hi_groups()

    local rainbow_delimiters = require("rainbow-delimiters")
    local highlight = {}
    for idx, group in ipairs(rainbow_hi_groups) do
        highlight[idx] = "RainbowDelimiter" .. group.name
    end

    vim.g.rainbow_delimiters = {
        strategy = {
            [""] = function()
                if vim.api.nvim_buf_line_count(0) > 10000 then return nil end
                return rainbow_delimiters.strategy["global"]
            end,
        },
        query = {
            [""] = "rainbow-delimiters",
        },
        highlight = highlight
    }
end
