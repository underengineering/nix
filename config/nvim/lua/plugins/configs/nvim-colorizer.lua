require("colorizer").setup {
    filetypes = {
        "*",
        css = { tailwind = true },
        svelte = { tailwind = true },
    },
    user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        css = true,
    }
}
