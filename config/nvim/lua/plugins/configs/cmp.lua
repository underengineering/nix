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

    local function pad(max, len)
        return (" "):rep(max - len)
    end

    -- Stolen from https://github.com/ditsuke/nvim-config/blob/f4e73301a80834ec8c834fcb680e69ed1c09b085/lua/ditsuke/plugins/editor/cmp.lua#L46
    ---@param completion lsp.CompletionItem
    ---@param source cmp.Source
    local function get_lsp_completion_context(completion, source)
        local src = source.source
        if src == nil then return end

        local client = src.client
        if client == nil then return end

        local source_name = client.config.name
        if source_name == "tsserver" then
            return completion.detail
        elseif source_name == "pyright" or source_name == "vtsls" then
            if completion.labelDetails ~= nil then
                return completion.labelDetails.description
            end
        elseif source_name == "gopls" then
            return completion.detail
        elseif source_name == "rust-analyzer" then
            local detail = completion.labelDetails.detail
            if detail ~= nil then
                -- Trim (use )
                return detail:sub(6, -2)
            end
            -- else
            -- print(source_name, vim.inspect(completion))
        end
    end

    -- Stolen from https://github.com/AlexvZyl/.dotfiles/blob/b4c7969ca50277b0d81fc93cfc9ccebf14aaca49/.config/nvim/lua/alex/lang/completion/ui.lua#L6
    ---@param entry cmp.Entry
    ---@param item vim.CompletedItem
    local function format(entry, item)
        local MAX_LABEL_WIDTH = 50

        local ctx = get_lsp_completion_context(entry.completion_item, entry.source)

        -- Limit content width.
        local content = item.abbr
        if #content > MAX_LABEL_WIDTH then
            ---@diagnostic disable-next-line: param-type-mismatch
            item.abbr = vim.fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. "…"
        else
            item.abbr = content
        end

        if ctx then
            local max_ctx_width = math.min(30, MAX_LABEL_WIDTH - #item.abbr - 3 - 2)
            if #ctx > max_ctx_width then
                ctx = ctx:sub(1, max_ctx_width) .. "..."
            end

            -- Right-align ctx
            item.abbr = item.abbr .. (" "):rep(math.max(2, MAX_LABEL_WIDTH - #item.abbr - #ctx)) .. ctx
        elseif #content < MAX_LABEL_WIDTH then
            item.abbr = item.abbr .. pad(MAX_LABEL_WIDTH, #content)
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
            debounce = 30,
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
