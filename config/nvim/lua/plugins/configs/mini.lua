local utils = require("utils")

require("mini.surround").setup()

if not utils.is_in_vscode then
    require("mini.files").setup()

    local modules = {
        create = require("lsp-file-operations.did-create"),
        delete = require("lsp-file-operations.did-delete"),
        rename = require("lsp-file-operations.did-rename"),
    }

    vim.api.nvim_create_autocmd("User", {
        pattern = { "MiniFilesActionCreate", "MiniFilesActionDelete", "MiniFilesActionRename" },
        callback = function(event)
            local module = modules[event.data.action]
            if not module then return end

            local old_name = event.data.from
            local new_name = event.data.to
            if old_name and new_name then
                module.callback({ old_name = old_name, new_name = new_name })
            else
                module.callback({ fname = old_name or new_name })
            end
        end
    })
end
