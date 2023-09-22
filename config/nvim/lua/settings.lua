vim.opt.number = true
vim.opt.relativenumber = true

-- Allow the neovim to access the system clipboard
-- vim.opt.clipboard = "unnamedplus"

-- Save undo state to a file
vim.opt.undofile = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4

vim.opt.ignorecase = true

vim.opt.timeout = true
vim.opt.timeoutlen = 400

vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Scrolling sensitivity
vim.opt.mousescroll = "ver:2,hor:4"

-- Show a column at 80 char
vim.opt.colorcolumn = "80"

-- Reserve some space for LSP diagnostics
vim.opt.signcolumn = "yes"

-- More frequent LSP action update
vim.opt.updatetime = 150

-- Highlight current line
vim.opt.cursorline = true

-- Enabled global statusline
vim.opt.laststatus = 3

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8

-- Minimal number of screen lines to keep left and right of the cursor.
vim.opt.sidescrolloff = 8

vim.opt.mouse = "a"

vim.opt.completeopt = "menu,menuone,noselect"

vim.opt.list = true
vim.opt.listchars:append "space:·"
vim.opt.listchars:append "tab:-->"

vim.g.python_recommended_style = 0

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank { higroup = "IncSearch", timeout = 400 }
    end,
    group = highlight_group,
    pattern = "*",
})

vim.api.nvim_create_user_command("ForEach", function(opts)
    vim.fn.execute(('%u,%ug//exe "normal! %s" | noh'):format(opts.line1, opts.line2, vim.fn.escape(opts.args, '"')))
end, {
    nargs = 1,
    complete = "mapping",
    range = "%"
})

-- Autoformat
local autoformat_group = vim.api.nvim_create_augroup("AutoFormat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        local config = require("formatter.config")
        local formatters = config.formatters_for_filetype(vim.bo.filetype)
        if #formatters > 0 then
            -- Format with formatter.nvim
            vim.cmd "FormatWriteLock"

            -- Cancel neovim's save
            vim.bo.modified = false

            -- Fix modifable flag
            vim.bo.modifiable = true
            return
        end

        -- Format with LSP
        local can_format = #vim.lsp.get_clients { bufnr = 0 } > 0
        -- Doesnt work
        -- for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
        --     if client.server_capabilities.formatting then
        --         can_format = true
        --         break
        --     end
        -- end
        --
        if can_format then
            vim.lsp.buf.format()
        end
    end,
    group = autoformat_group,
    pattern = "*",
})
