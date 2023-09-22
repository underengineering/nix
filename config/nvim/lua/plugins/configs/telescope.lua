return function()
    local telescope = require("telescope")

    local ui_select_config = {
        layout_strategy = "vertical",
        layout_config = {
            prompt_position = "bottom",
            vertical = {
                width = 0.5,
                height = 0.4,
            }
        }
    }

    telescope.setup {
        extensions = {
            ["ui-select"] = {
                require("telescope.themes").get_dropdown(ui_select_config)
            },
            ast_grep = {
                command = {
                    "ast-grep",
                    "run",
                    "--json=stream",
                },
                grep_open_files = false,
                lang = nil,
            }
        }
    }

    telescope.load_extension("ui-select")
    telescope.load_extension("ast_grep")
end
