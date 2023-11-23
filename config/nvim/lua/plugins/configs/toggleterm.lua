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
            hidden = true,
            on_close = function()
                vim.cmd("Gitsigns refresh")
            end
        })
    end

    lazygit:toggle()
end)
