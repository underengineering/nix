local get_color = require("utils").get_color

vim.api.nvim_set_hl(0, "StatusLine", {
    fg = get_color("StatusLine", "fg#"),
    bg = get_color("StatusLine", "bg#"),
})
