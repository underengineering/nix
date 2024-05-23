local utils = require("utils")

require("mini.surround").setup()

if not utils.is_in_vscode then
    require("mini.files").setup()
end
