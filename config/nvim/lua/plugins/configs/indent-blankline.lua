return function()
    local palette = require("gruvbox.palette")
    vim.api.nvim_set_hl(0, "IndentBlanklineSpaceChar", {
        fg = palette.dark2
    })

    vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", {
        fg = palette.light4
    })

    vim.api.nvim_set_hl(0, "IndentBlanklineContextStart", {
        sp = palette.light4,
        underline = true
    })

    require("ibl").setup {
        show_current_context = true,
        show_current_context_start = true
    }
end
