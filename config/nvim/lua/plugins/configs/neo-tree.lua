return function(_, opts)
    vim.g.neo_tree_remove_legacy_commands = true

    -- require("oil").setup()

    require("neo-tree").setup {
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = true,

        default_component_configs = {
            indent = {
                indent_size = 2,
                padding = 1,

                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "└",
                highlight = "NeoTreeIndentMarker",

                with_expanders = nil,
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander"
            },
            icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "",
                highlight = "NeoTreeFileIcon"
            },
            modified = {
                symbol = "",
                highlight = "NeoTreeModified"
            },
            name = {
                trailing_slash = false,
                use_git_status_colors = true,
                highlight = "NeoTreeFileName"
            },
            git_status = {
                symbols = {
                    deleted   = "✖",
                    renamed   = "󰁕",
                    untracked = "",
                    ignored   = "",
                    unstaged  = "󰄱",
                    staged    = "",
                    conflict  = "",
                }
            }
        },
        window = {
            position = "left",
            width = 40,
            mapping_options = {
                noremap = true,
                nowait = true
            },
            mappings = {
                -- ["<Space>"] = {
                --     "toggle_node",
                --     nowait = true
                -- },
                ["<2-LeftMouse>"] = "open",
                ["<Cr>"] = "open",
                ["Esc"] = "revert_preview",
                ["a"] = {
                    "add",
                    config = { show_path = "relative" }
                },
                ["d"] = "delete",
                ["r"] = "rename",
                ["y"] = "copy_to_clipboard",
                ["x"] = "cut_to_clipboard",
                ["p"] = "paste_from_clipboard",
                ["c"] = "copy",
                ["m"] = "move",
                ["q"] = "close_window",
                ["R"] = "refresh"
            }
        },
        filesystem = {
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_hidden = false,
                hide_by_name = {},
                hide_by_pattern = {},
                always_show = {},
                never_show = {}
            },
            follow_current_file = { enabled = true },
            group_empty_dirs = false,
            hijack_netrw_behavior = "open_default",
            use_libuv_file_watcher = true
        },
        buffers = {
            follow_current_file = { enabled = true },
            group_empty_dirs = false,
            show_unloaded = true,
            window = {
                mappings = {

                }
            }
        },
        git_status = {

        }
    }
end
