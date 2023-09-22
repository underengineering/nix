local lsp_signature_cfg = {
    bind = true,
    handler_opts = {
        border = "rounded"
    }
}

local lsp = require("lsp-zero").preset {
    float_border = "rounded",
    manage_nvim_cmp = false
}

local navic = require("nvim-navic")

local notifiedServers = {}
lsp.on_attach(function(client, bufnr)
    require "lsp_signature".on_attach(lsp_signature_cfg, bufnr)

    lsp.default_keymaps({ buffer = bufnr })
    if not notifiedServers[client.name] then
        local symbols_supported = client.supports_method("textDocument/documentSymbol")
        if not symbols_supported then
            print(("Symbols are not supported by %s"):format(client.name))
            notifiedServers[client.name] = true
            return
        end
    end

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint(bufnr, true)
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
                    snippetSupport = true
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

    "clangd",
    "cmake",
    "nil_ls",
    "prismals",
    "taplo",
}

lsp.skip_server_setup({ "rust_analyzer" })

lsp.configure("lua_ls", {
    opts = {
        Lua = {
            telemetry = {
                enable = false
            }
        }
    }
})

lsp.configure("jsonls", {
    opts = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true }
        }
    }
})

-- require("lspconfig").lua_ls.setup {
--     settings = {
--         Lua = {
--             telemetry = {
--                 enable = false
--             }
--         }
--     }
-- }

-- require("lspconfig").jsonls.setup {
--     settings = {
--         json = {
--             schemas = require("schemastore").json.schemas(),
--             validate = { enable = true }
--         }
--     }
-- }

local function defineSign(name, symbol)
    vim.fn.sign_define(name, { texthl = name, text = symbol, numhl = "", icon = "" })
end

local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" }
}

for _, sign in ipairs(signs) do
    defineSign(sign.name, sign.text)
end

vim.diagnostic.config {
    virtual_text = { prefix = "●" },
    signs = { active = signs },
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

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
    { update_in_insert = true })

lsp.setup()

require("rust-tools").setup {
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
