---@return boolean Is lazy.nvim bootstrapped
local function bootstrap_lazy()
    local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    vim.opt.rtp:prepend(install_path)

    if not vim.loop.fs_stat(install_path) then
        print("Lazy.nvim not found, bootstrapping")

        vim.fn.system { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", install_path }

        return true
    end

    return false
end

bootstrap_lazy()

require("keybinds")
require("settings")

local plugins = require("plugins")
require("lazy").setup(plugins)

local is_vscode = vim.g.vscode ~= nil
if not is_vscode then require("highlight") end
