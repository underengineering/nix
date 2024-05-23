-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank { higroup = "IncSearch", timeout = 400 }
    end,
    group = highlight_group,
    pattern = "*",
})

-- Autoformat
local auto_format = true
vim.api.nvim_create_user_command("AutoFormatEnable", function()
    auto_format = true
end, {})

vim.api.nvim_create_user_command("AutoFormatDisable", function()
    auto_format = false
end, {})

local autoformat_group = vim.api.nvim_create_augroup("AutoFormat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        if not auto_format then return end

        local config = require("formatter.config")
        local formatters = config.formatters_for_filetype(vim.bo.filetype)
        if #formatters > 0 then
            -- Format with formatter.nvim
            -- TODO: show completion progress using FormatterPost
            vim.cmd "FormatWriteLock"

            -- Cancel neovim's save
            vim.bo.modified = false

            -- Fix modifable flag
            vim.bo.modifiable = true
            return
        end

        -- Format with LSP
        local can_format = #vim.lsp.get_clients { bufnr = 0 } > 0
        local mode = vim.api.nvim_get_mode()
        local clients = vim.lsp.get_clients {
            bufnr = 0,
            method = (mode == "v" or mode == "V") and "textDocument/rangeFormatting" or "textDocument/formatting",
        }
        if can_format and #clients > 0 then
            vim.lsp.buf.format()
        end
    end,
    group = autoformat_group,
    pattern = "*",
})
