return function()
    local get_color = require("utils").get_color

    require("leap").add_default_mappings()
    vim.api.nvim_set_hl(0, "LeapLabelPrimary", {
        bg = get_color("DiagnosticOk", "fg#"),
        fg = get_color("Normal", "bg#")
    })

    vim.api.nvim_set_hl(0, "LeapLabelSecondary", {
        bg = get_color("DiagnosticWarn", "fg#"),
        fg = get_color("Normal", "bg#")
    })
end
