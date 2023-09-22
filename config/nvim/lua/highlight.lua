--[[ local get_color = require("utils").get_color
local palette = require("gruvbox.palette").get_base_colors()

-- Set floating window background color to the same color as buffer background
vim.api.nvim_set_hl(0, "NormalFloat", {
    fg = get_color("Normal", "fg#"),
    bg = palette.bg1
})

vim.api.nvim_set_hl(0, "FloatBorder", {
    fg = palette.bg2,
    bg = get_color("FloatBorder", "bg#")
})

vim.api.nvim_set_hl(0, "LspInfoBorder", {
    fg = palette.bg2,
    bg = get_color("LspInfoBorder", "bg#")
})

vim.api.nvim_set_hl(0, "NoiceLspProgressTitle", {
    fg = palette.fg0,
    bg = get_color("NoiceLspProgressTitle", "bg#")
})
]]
