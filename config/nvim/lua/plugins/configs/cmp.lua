return function()
    local cmp = require("cmp")

    local bordered_window = cmp.config.window.bordered()
    bordered_window.winhighlight = "Normal:Normal,NormalFloat:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual"

    local KIND_ICONS = {
        Text = "",
        Codeium = "󰚩",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰇽",
        Variable = "󰂡",
        Class = "󰠲",
        Interface = "",
        Module = "󰆧",
        Property = "󰜢",
        Unit = "",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "󰅲"
    }

    local sources = {
        { name = "codeium",   priority = 1050 },
        { name = "nvim_lsp",  priority = 1000 },
        { name = "luasnip",   priority = 750 },
        { name = "buffer",    priority = 500 },
        { name = "path",      priority = 250 },
        { name = "calc" },
        { name = "emoji" },
        { name = "treesitter" },
        { name = "crates" },
    }

    -- Stolen from https://github.com/AlexvZyl/.dotfiles/blob/b4c7969ca50277b0d81fc93cfc9ccebf14aaca49/.config/nvim/lua/alex/lang/completion/ui.lua#L6
    local function format(_, item)
        local MAX_LABEL_WIDTH = 50
        local function pad(max, len)
            return (" "):rep(max - len)
        end

        -- Limit content width.
        local content = item.abbr
        if #content > MAX_LABEL_WIDTH then
            item.abbr = vim.fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. "…"
        else
            item.abbr = content .. pad(MAX_LABEL_WIDTH, #content)
        end

        -- Replace kind with icons.
        item.kind = (" %s │"):format(KIND_ICONS[item.kind])

        -- Remove gibberish.
        item.menu = nil

        return item
    end

    cmp.setup {
        active = true,
        performance = {
            debounce = 60,
            throttle = 30,
            fetching_timeout = 500,
            confirm_resolve_timeout = 80,
            async_budget = 5,
            max_view_entries = 100
        },
        preselect = "item",
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        window = {
            completion = bordered_window,
            documentation = bordered_window,
        },
        formatting = {
            expandable_indicator = true,
            fields = { "kind", "abbr" },
            format = format,
        },
        mapping = cmp.mapping.preset.insert {
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<C-Space>"] = cmp.mapping.complete {},
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm { select = true },
        },
        sources = sources,
        sorting = {
            priority_weight = 2,
            comparators = {
                cmp.config.compare.score,
                require "cmp-under-comparator".under,
                cmp.config.compare.recently_used,
                cmp.config.compare.locality,
                cmp.config.compare.offset,
                cmp.config.compare.order
            }
        },
        experimental = {
            ghost_text = true
        }
    }

    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "buffer" }
        }
    })

    cmp.setup.cmdline({ ":" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "cmdline" },
            { name = "path" }
        })
    })

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end
