local lspconfig = require("lspconfig")

local lsp = require("lsp-zero").preset {
    float_border = "rounded",
    manage_nvim_cmp = false
}

local navic = require("nvim-navic")

local lsp_signature_cfg = {
    bind = true,
    handler_opts = {
        border = "rounded"
    }
}

lsp.on_attach(function(client, bufnr)
    require "lsp_signature".on_attach(lsp_signature_cfg, bufnr)

    lsp.default_keymaps({ buffer = bufnr })

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(bufnr, true)
    end

    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end
end)

lsp.set_server_config {
    capabilities = {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = false
                }
            }
        }
    }
}

lsp.setup_servers {
    "gopls",

    "pyright",
    "ruff_lsp",

    "cssls",
    "eslint",
    "html",
    "svelte",
    "tailwindcss",
    "tsserver",

    "prismals",
    "taplo",
    "yamlls",

    "clangd",
    "cmake",

    "nil_ls",

    "zls"
}

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
            source = "always",
            header = "",
            prefix = ""
        }
    }

    lsp.set_sign_icons(utils.diagnostic_signs)
end

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
            { "╭", "FloatBorder" },
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
