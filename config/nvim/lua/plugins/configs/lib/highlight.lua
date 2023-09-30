local _M = {}

local palette = require("gruvbox.palette").get_base_colors({}, nil, "")
local rainbow_hi_groups = {
    { name = "Red",    fg = palette.red },
    { name = "Orange", fg = palette.orange },
    { name = "Yellow", fg = palette.yellow },
    { name = "Green",  fg = palette.green },
    { name = "Aqua",   fg = palette.aqua },
    { name = "Blue",   fg = palette.blue },
    { name = "Purple", fg = palette.purple },
}

_M.rainbow_hi_groups = rainbow_hi_groups

return _M
