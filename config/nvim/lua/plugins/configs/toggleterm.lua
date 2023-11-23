require("toggleterm").setup {
    shade_terminals = false
}

local Terminal = require("toggleterm.terminal").Terminal

---@type Terminal | nil
local lazygit

vim.keymap.set("n", "<Leader>g", function()
    if not lazygit then
        lazygit = Terminal:new({
            cmd = "lazygit",
            direction = "float",
            hidden = true
        })
    end

    lazygit:toggle()
end)
