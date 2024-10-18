return function()
    local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")

    ---@param client vim.lsp.Client
    ---@param bufnr integer
    local function on_attach(client, bufnr)
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
    end

    for _, server_name in ipairs {
        "gopls",
        "golangci_lint_ls",

        "pyright",
        "ruff_lsp",

        "cssls",
        "eslint",
        "html",
        "svelte",
        "tailwindcss",

        "prismals",
        "taplo",
        "yamlls",

        "clangd",
        "cmake",

        "nil_ls",

        "zls"

    } do
        lspconfig[server_name].setup {
            on_attach = on_attach,
            capabilities = lsp_capabilities
        }
    end

    -- lspconfig.svelte.setup {
    --     cmd = { "pnpm", "svelteserver", "--stdio" }
    -- }

    lspconfig.lua_ls.setup {
        settings = {
            Lua = {
                telemetry = {
                    enable = false
                }
            }
        }
    }

    lspconfig.jsonls.setup {
        settings = {
            json = {
                schemas = require("schemastore").json.schemas(),
                validate = { enable = true }
            }
        }
    }

    do
        local utils = require("utils")
        local signs = {
            [vim.diagnostic.severity.ERROR] = utils.diagnostic_signs.error,
            [vim.diagnostic.severity.WARN] = utils.diagnostic_signs.warn,
            [vim.diagnostic.severity.INFO] = utils.diagnostic_signs.info,
            [vim.diagnostic.severity.HINT] = utils.diagnostic_signs.hint,
        }

        vim.diagnostic.config {
            signs = { text = signs },
            virtual_text = { prefix = "●" },
            update_in_insert = true,
            underline = true,
            severity_sort = true,
            float = {
                focused = false,
                style = "minimal",
                border = "rounded",
                source = true,
                header = "",
                prefix = ""
            },
        }
    end

    ---@type RustaceanConfig
    vim.g.rustaceanvim = {
        tools = {
            reload_workspace_from_cargo_toml = true,
            inlay_hints = {
                auto = true,
                only_current_line = true,
                show_parameter_hints = true,
                parameter_hints_prefix = "<- ",
                other_hints_prefix = "=> ",
                max_len_align = false,
                max_len_align_padding = 1,
                right_align = false,
                right_align_padding = 7,
                highlight = "Comment"
            }
        },
        hover_actions = {
            border = {
                { "╭", "FlatBorder" },
                { "─", "FloatBorder" },
                { "╮", "FloatBorder" },
                { "│", "FloatBorder" },
                { "╯", "FloatBorder" },
                { "─", "FloatBorder" },
                { "╰", "FloatBorder" },
                { "│", "FloatBorder" },
            },
            auto_focus = false
        },
        server = {
            standalone = false,
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = { command = "clippy" }
                }
            }
        }
    }
end
