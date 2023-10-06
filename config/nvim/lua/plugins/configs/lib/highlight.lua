local _M = {}

local palette = require("gruvbox").palette
local rainbow_hi_groups = {
    { name = "Red",    fg = palette.bright_red },
    { name = "Orange", fg = palette.bright_orange },
    { name = "Yellow", fg = palette.bright_yellow },
    { name = "Green",  fg = palette.bright_green },
    { name = "Aqua",   fg = palette.bright_aqua },
    { name = "Blue",   fg = palette.bright_blue },
    { name = "Purple", fg = palette.bright_purple },
}

_M.rainbow_hi_groups = rainbow_hi_groups

return _M
