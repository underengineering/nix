local is_in_vscode = require("utils").is_in_vscode

local new_plugins = {
    require("plugins.themes"),
    require("plugins.core"),
}

if not is_in_vscode then
    local extra_plugins = {
        require("plugins.lsp"),
        require("plugins.cmp"),
        require("plugins.treesitter"),
        require("plugins.telescope"),
        require("plugins.neo-tree"),
    }

    for i = 1, #extra_plugins do
        new_plugins[#new_plugins + 1] = extra_plugins[i]
    end
end

return new_plugins
