return function()
    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")

    local get_color = require("utils").get_color
    local palette = require("gruvbox").palette


    ---@class Align: StatusLine
    local Align = { provider = "%=" }

    ---@class Space: StatusLine
    local Space = { provider = " " }

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
                ["NORMAL"]    = { fg = palette.light0, bg = palette.dark2 },
                ["O-PENDING"] = { fg = palette.light0, bg = palette.dark2 },
                ["VISUAL"]    = { bg = palette.bright_orange },
                ["V-LINE"]    = { bg = palette.bright_orange },
                ["V-BLOCK"]   = { bg = palette.bright_orange },
                ["INSERT"]    = { bg = palette.bright_green },
                ["REPLACE"]   = { bg = palette.bright_red },
                ["V-REPLACE"] = { bg = palette.bright_red },
                ["COMMAND"]   = { fg = palette.light0, bg = palette.dark4 },
                ["TERMINAL"]  = { fg = palette.light0, bg = palette.dark4 }
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
            local rec = vim.fn.reg_recording()
            if rec ~= "" then
                rec = "@" .. rec
            end

            return (" %%4(%s%s%%) "):format(self.mode_name, rec)
        end,
        ---@param self ViMode
        hl = function(self)
            local hl = self.colors[self.mode_name]
            if hl then
                ---@type table<string, string | boolean>
                ---@diagnostic disable-next-line: assign-type-mismatch
                hl = vim.fn.copy(hl)
                hl.fg = hl.fg or palette.dark1
                hl.bold = true
            end

            return hl
        end,
        update = { "ModeChanged", "RecordingEnter", "RecordingLeave" }
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
                    hl.bg = palette.dark1
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
            {
                provider = " ("
            },
            {
                ---@param self Git
                provider = function(self)
                    return " " .. self.status_dict.added
                end,
                ---@param self Git
                condition = function(self) return self.status_dict.added > 0 end,
                hl = "GitSignsAdd",
            },
            {
                provider = " ",

                ---@param self Git
                condition = function(self)
                    return self.status_dict.added > 0 and self.status_dict.removed > 0
                end
            },
            {
                ---@param self Git
                provider = function(self)
                    return " " .. self.status_dict.removed
                end,
                ---@param self Git
                condition = function(self) return self.status_dict.removed > 0 end,
                hl = "GitSignsDelete",
            },
            {
                provider = " ",

                ---@param self Git
                condition = function(self)
                    return (self.status_dict.added > 0 or self.status_dict.removed > 0) and
                        self.status_dict.changed > 0
                end
            },
            {
                ---@param self Git
                provider = function(self)
                    return " " .. self.status_dict.changed
                end,
                ---@param self Git
                condition = function(self) return self.status_dict.changed > 0 end,
                hl = "GitSignsChange",
            },
            {
                provider = ")"
            },
            ---@param self Git
            condition = function(self) return self.has_changes end
        },
        hl = { fg = palette.neutral_yellow, bg = palette.dark1 },
        update = { "User", pattern = "GitSignsUpdate" },
        ---@param self Git
        condition = function(self) return self.status_dict and conditions.is_git_repo() end,
    }

    ---@class FileNameBlock: StatusLine
    ---@field file_name string
    local FileNameBlock = {
        ---@param self FileNameBlock
        init   = function(self)
            self.file_name = vim.api.nvim_buf_get_name(0)
        end,
        hl     = { bg = palette.dark1 },
        update = { "BufEnter", "BufModifiedSet" }
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
        hl = { fg = palette.light0 }
    }

    ---@class FileFlags: StatusLine
    local FileFlags = {
        {
            condition = function()
                return vim.bo.modified
            end,
            provider = " 󰷫",
            hl = { fg = palette.bright_green },
        },
        {
            condition = function()
                return not vim.bo.modifiable or vim.bo.readonly
            end,
            provider = "",
            hl = { fg = palette.bright_red },
        },
    }

    ---@class FileNameModifier: FileName
    local FileNameModifier = {
        hl = function()
            if vim.bo.modified then
                return { fg = palette.bright_green, bold = true, force = true }
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

    local diagnostic_icons = require("utils").diagnostic_signs

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
        static = {
            error_icon = diagnostic_icons.error,
            warn_icon = diagnostic_icons.warn,
            info_icon = diagnostic_icons.info,
            hint_icon = diagnostic_icons.hint
        },
        ---@param self Diagnostics
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        end,
        { provider = "", hl = { fg = palette.dark2, bg = palette.dark1 } },
        Space,
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.errors > 0 and ("%s %u "):format(self.error_icon, self.errors)
            end,
            hl = { fg = get_color("DiagnosticError", "fg#") }
        },
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.warnings > 0 and ("%s %u "):format(self.warn_icon, self.warnings)
            end,
            hl = { fg = get_color("DiagnosticWarn", "fg#") }
        },
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.info > 0 and ("%s %u "):format(self.info_icon, self.info)
            end,
            hl = { fg = get_color("DiagnosticInfo", "fg#") }
        },
        {
            ---@param self Diagnostics
            provider = function(self)
                return self.hints > 0 and ("%s %u "):format(self.hint_icon, self.hints)
            end,
            hl = { fg = get_color("DiagnosticHint", "fg#") }
        },
        hl = { bg = palette.dark2 },
        condition = conditions.has_diagnostics,
        update = { "DiagnosticChanged", "BufEnter" },
    }

    ---@class ActiveLsp: StatusLine
    local ActiveLsp = {
        condition = function() return #vim.lsp.get_clients { bufnr = 0 } > 0 end,
        { provider = "", hl = { fg = palette.dark1, bg = palette.dark4 } },
        {
            provider = " ",
        },
        {
            provider = " ",
            hl = { fg = palette.bright_orange }
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
        hl = { fg = palette.light0, bg = palette.dark1 },
        update = { "LspAttach", "LspDetach" },
    }

    ---@class Ruler: StatusLine
    local Ruler = {
        -- %l = current line number
        -- %L = number of lines in the buffer
        -- %c = column number
        -- %P = percentage through file of displayed window
        provider = " %7(%l/%3L%):%2c %P ",
        hl = { fg = palette.light0, bg = palette.dark3 }
    }

    local status_line = {
        -- Left
        ViModePowerline,
        Git,
        FileNameBlock,
        { provider = "", hl = { fg = palette.dark1 } },

        Align,
        -- Align,

        -- Right
        ActiveLsp,
        Diagnostics,
        { provider = "", hl = { fg = palette.dark3, bg = palette.dark2 } },
        Ruler,
        hl = { bg = palette.dark4 }
    }

    require("heirline").setup {
        statusline = status_line
    }
end
