local M = {}

M.is_in_vscode = vim.g.vscode ~= nil

---@return string The color
function M.get_color(group, attr)
    local hlId = vim.fn.hlID(group)
    return vim.fn.synIDattr(vim.fn.synIDtrans(hlId), attr)
end

return M
