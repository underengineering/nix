return function()
    local get_color = require("utils").get_color

    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")

    local palette = require("gruvbox.palette").get_base_colors({}, nil, "")

    ---@class Align: StatusLine
    local Align = { provider = "%=" }

    ---@class Space: StatusLine
    local Space = { provider = " " }

    -- "" ""

    ---@class ViMode: StatusLine
    ---@field names table<string, string>
    ---@field colors table<string, table<string, string | boolean>>
    ---@field mode string
    ---@field mode_name string
    ---@field mode_hl table<string, string | boolean>
    ---@field once boolean
    local ViMode = {
        static = {
            names = {
                n         = "NORMAL",
                no        = "O-PENDING",
                nov       = "O-PENDING",
                noV       = "O-PENDING",
                ["no\22"] = "O-PENDING",
                niI       = "NORMAL",
                niR       = "NORMAL",
                niV       = "NORMAL",
                nt        = "NORMAL",
                ntT       = "NORMAL",
                v         = "VISUAL",
                vs        = "VISUAL",
                V         = "V-LINE",
                Vs        = "V-LINE",
                ["\22"]   = "V_BLOCK",
                ["\22s"]  = "V-BLOCK",
                s         = "SELECT",
                S         = "S-LINE",
                ["\19"]   = "S-BLOCK",
                i         = "INSERT",
                ic        = "INSERT",
                ix        = "INSERT",
                R         = "REPLACE",
                Rc        = "REPLACE",
                Rx        = "REPLACE",
                Rv        = "V-REPLACE",
                Rvc       = "V-REPLACE",
                Rvx       = "V-REPLACE",
                c         = "COMMAND",
                cv        = "EX",
                ce        = "EX",
                r         = "REPLACE",
                rm        = "MORE",
                ["r?"]    = "CONFIRM",
                ["!"]     = "SHELL",
                t         = "TERMINAL"
            },
            colors = {
                ["NORMAL"]    = { fg = palette.fg0, bg = palette.bg2 },
                ["O-PENDING"] = { fg = palette.fg0, bg = palette.bg2 },
                ["VISUAL"]    = { bg = palette.orange },
                ["V-LINE"]    = { bg = palette.orange },
                ["V-BLOCK"]   = { bg = palette.orange },
                ["INSERT"]    = { bg = palette.green },
                ["REPLACE"]   = { bg = palette.red },
                ["V-REPLACE"] = { bg = palette.red },
                ["COMMAND"]   = { fg = palette.fg0, bg = palette.bg4 },
                ["TERMINAL"]  = { fg = palette.fg0, bg = palette.bg4 }
            },
        },
        ---@param self ViMode
        init = function(self)
            local mode = vim.fn.mode(1)
            if mode == nil then return end

            self.mode = mode
            self.mode_name = self.names[self.mode]
            self.mode_hl = self.colors[self.mode_name]
            if not self.once then
                vim.api.nvim_create_autocmd("ModeChanged", {
                    pattern = "*:*o",
                    command = "redrawstatus"
                })

                self.once = true
            end
        end,
        ---@param self ViMode
        provider = function(self)
            return (" %%2(%s%%) "):format(self.mode_name)
        end,
        ---@param self ViMode
        hl = function(self)
            local hl = self.colors[self.mode_name]
            if hl then
                ---@type table<string, string | boolean>
                ---@diagnostic disable-next-line: assign-type-mismatch
                hl = vim.fn.copy(hl)
                hl.fg = hl.fg or palette.bg1
                hl.bold = true
            end

            return hl
        end,
        update = { "ModeChanged" }
    }

    ---@class ViModePowerline: ViMode
    local ViModePowerline = utils.insert(ViMode, {
        {
            provider = " ",
            ---@param self ViMode
            hl = function(self)
                local hl = self.colors[self.mode_name]
                if hl then
                    ---@type table<string, string | boolean>
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    hl = vim.fn.copy(hl)

                    -- Invert colors
                    hl.fg = hl.bg
                    hl.bg = palette.bg1
                end

                return hl
            end
        },
    })

    ---@alias GitSignsInfo { added: number, removed: number, changed: number, head: string }

    ---@class Git: StatusLine
    ---@field status_dict GitSignsInfo
    ---@field has_changes boolean
    local Git = {
        condition = function() return vim.b.gitsigns_status_dict and conditions.is_git_repo() end,

        ---@param self Git
        init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or
                self.status_dict.changed ~= 0
        end,
        {
            ---@param self Git
            provider = function(self)
                return " " .. self.status_dict.head
            end,
            hl = { bold = true }
        },
        {
            ---@param self Git
            provider = function(self)
                if self.has_changes then return "(" end
            end
        },
        {
            ---@param self Git
            provider = function(self)
                if (self.status_dict.added or 0) > 0 then
                    return " " .. self.status_dict.added
                end
            end,
            hl = "GitSignsAdd",
        },
        {
            ---@param self Git
            provider = function(self)
                if (self.status_dict.removed or 0) > 0 then
                    return "  " .. self.status_dict.removed
                end
            end,
            hl = "GitSignsDelete",
        },
        {
            ---@param self Git
            provider = function(self)
                if (self.status_dict.changed or 0) > 0 then
                    return "  " .. self.status_dict.changed
                end
            end,
            hl = "GitSignsChange",
        },
        {
            ---@param self Git
            provider = function(self)
                if self.has_changes then return ")" end
            end
        },
        hl = { fg = palette.neutral_yellow, bg = palette.bg1 }
    }

    ---@class FileNameBlock: StatusLine
    ---@field file_name string
    local FileNameBlock = {
        ---@param self FileNameBlock
        init = function(self)
            self.file_name = vim.api.nvim_buf_get_name(0)
        end,
        hl = { bg = palette.bg1 }
    }

    ---@class FileIcon: FileNameBlock
    ---@field icon string
    ---@field icon_color string
    local FileIcon = {
        ---@param self FileIcon
        init = function(self)
            local file_name = self.file_name
            local extension = vim.fn.fnamemodify(file_name, ":e")
            self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(file_name, extension,
                { default = true })
        end,
        ---@param self FileIcon
        provider = function(self)
            return self.icon and (self.icon .. " ")
        end,
        ---@param self FileIcon
        hl = function(self)
            return { fg = self.icon_color }
        end
    }

    ---@class FileName: FileNameBlock
    local FileName = {
        ---@param self FileName
        provider = function(self)
            -- Get relative file name
            local file_name = vim.fn.fnamemodify(self.file_name, ":.")
            if file_name == "" then return "" end

            if not conditions.width_percent_below(#file_name, 0.25) then
                file_name = vim.fn.pathshorten(file_name)
            end

            return file_name
        end,
        hl = { fg = palette.fg0 }
    }

    ---@class FileFlags: StatusLine
    local FileFlags = {
        {
            condition = function()
                return vim.bo.modified
            end,
            provider = "[+]",
            hl = { fg = palette.green },
        },
        {
            condition = function()
                return not vim.bo.modifiable or vim.bo.readonly
            end,
            provider = "",
            hl = { fg = palette.red },
        },
    }

    ---@class FileNameModifier: FileName
    local FileNameModifier = {
        hl = function()
            if vim.bo.modified then
                return { fg = palette.green, bold = true, force = true }
            end
        end
    }

    FileNameBlock = utils.insert(FileNameBlock,
        { provider = " ", hl = FileNameBlock.hl },
        FileIcon,
        utils.insert(FileNameModifier, FileName),
        FileFlags,
        { provider = " %<" }
    )

    ---@class Diagnostics: StatusLine
    ---@field error_icon string
    ---@field warn_icon string
    ---@field info_icon string
    ---@field hint_icon string
    ---@field errors number
    ---@field warnings number
    ---@field info number
    ---@field hints number
    local Diagnostics = {
        condition = conditions.has_diagnostics,
        static = {
            error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
            warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
            info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
            hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
        },
        ---@param self Diagnostics
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        end,
        on_click = {
            callback = function()
                require("trouble").toggle { mode = "document_diagnostics" }
            end,
            name = "heirline_diagnostics",
        },
        update = { "DiagnosticChanged", "BufEnter" },
        { provider = "", hl = { fg = palette.bg2, bg = palette.bg1 } },
        Space,
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.errors > 0 and ("%s%u "):format(self.error_icon, self.errors)
            end,
            hl = { fg = get_color("DiagnosticError", "fg#") }
        },
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.warnings > 0 and ("%s%u "):format(self.warn_icon, self.warnings)
            end,
            hl = { fg = get_color("DiagnosticWarn", "fg#") }
        },
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.info > 0 and ("%s%u "):format(self.info_icon, self.info)
            end,
            hl = { fg = get_color("DiagnosticInfo", "fg#") }
        },
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.hints > 0 and ("%s%u "):format(self.hint_icon, self.hints)
            end,
            hl = { fg = get_color("DiagnosticHint", "fg#") }
        },
        hl = { bg = palette.bg2 }
    }

    local navic = require("nvim-navic")
    local navic_lib = require("nvim-navic.lib")

    ---@class Navic: StatusLine
    ---@field encode_scope fun(start_line:number, start_char:number, winnr:number):number
    ---@field decode_scope fun(value:number):number,number,number
    ---@field child table?
    local Navic = {
        static = {
            ---@param start_line number
            ---@param start_char number
            ---@param winnr number
            ---@return number
            encode_scope = function(start_line, start_char, winnr)
                return bit.bor(bit.lshift(start_line, 16), bit.lshift(start_char, 6), winnr)
            end,
            ---@param value number
            ---@return number, number, number
            decode_scope = function(value)
                local start_line = bit.rshift(value, 16)
                local start_char = bit.band(bit.rshift(value, 60), 1023)
                local winnr = bit.band(value, 63)
                return start_line, start_char, winnr
            end
        },
        condition = function()
            if not navic.is_available() then return false end

            local bufnr = vim.api.nvim_get_current_buf()
            local ctx = navic_lib.get_context_data(bufnr)
            if not ctx or #ctx <= 1 then return false end

            return true
        end,
        ---@param self Navic
        init = function(self)
            local data = navic.get_data() or {}
            local children = {
            }

            -- Create a child for each context
            for idx, ctx in ipairs(data) do
                local minwid = self.encode_scope(ctx.scope.start.line,
                    ctx.scope.start.character,
                    self.winnr)

                local hl = utils.get_highlight("NavicIcons" .. ctx.type)
                local child = {
                    {
                        provider = ctx.icon,
                        hl = { fg = hl.fg }
                    },
                    {
                        -- Escape %'s
                        provider = ctx.name:gsub("%%", "%%%%"),
                        on_click = {
                            minwid = minwid,
                            callback = function()
                                local start_line, start_char, winnr = self.decode_scope(minwid)
                                local win_id = vim.fn.win_getid(winnr)
                                if win_id == nil then
                                    return
                                end

                                vim.api.nvim_win_set_cursor(win_id, { start_line, start_char })
                            end,
                            name = "heirline_navic",
                        },
                        hl = { fg = palette.fg0 }
                    }
                }

                -- Add a separator if needed
                if idx < #data then
                    child[#child + 1] = {
                        provider = " > ",
                        hl = { fg = palette.fg0 }
                    }
                end

                children[idx] = child
            end


            if #children > 0 then
                table.insert(children, 1, Space)
                children[#children + 1] = Space
            end

            self.child = self:new(children, 1)
        end,
        { provider = "", hl = { fg = palette.bg1, bg = palette.bg4 } },
        {
            ---@param self Navic
            provider = function(self)
                return self.child:eval()
            end,
        },
        { provider = "", hl = { fg = palette.bg1, bg = palette.bg4 } },
        hl = { bg = palette.bg1 },
        update = "CursorMoved"
    }

    ---@class ActiveLsp: StatusLine
    local ActiveLsp = {
        condition = function() return #vim.lsp.get_clients { bufnr = 0 } > 0 end,
        { provider = "", hl = { fg = palette.bg1, bg = palette.bg4 } },
        {
            provider = " ",
        },
        {
            provider = " ",
            hl = { fg = palette.orange }
        },
        {
            provider = function()
                local names = {}
                for _, server in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
                    names[#names + 1] = server.name
                end

                return (" %s "):format(table.concat(names, " "))
            end,
        },
        {
            provider = "",
        },
        Space,
        hl = { fg = palette.fg0, bg = palette.bg1 },
        -- update = { "LspAttach", "LspDetach" },
    }

    ---@class Ruler: StatusLine
    local Ruler = {
        -- %l = current line number
        -- %L = number of lines in the buffer
        -- %c = column number
        -- %P = percentage through file of displayed window
        provider = " %7(%l/%3L%):%2c %P ",
        hl = { bg = palette.bg3 }
    }

    local status_line = {
        -- Left
        ViModePowerline,
        Git,
        FileNameBlock,
        { provider = "", hl = { fg = palette.bg1 } },

        Align,
        Navic,
        Align,

        -- Right
        ActiveLsp,
        Diagnostics,
        { provider = "", hl = { fg = palette.bg3, bg = palette.bg2 } },
        Ruler,
        hl = { bg = palette.bg4 }
    }

    require("heirline").setup {
        statusline = status_line
    }
end
