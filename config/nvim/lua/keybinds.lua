local keymap = vim.keymap

local opts = {
    silent = true,
}

vim.g.mapleader = " "

local is_vscode = vim.g.vscode ~= nil
local function with_desc(tbl, desc)
    local new_opts = vim.fn.deepcopy(tbl)
    new_opts.desc = desc
    return new_opts
end

local function as_expr(tbl)
    local new_opts = vim.fn.deepcopy(tbl)
    new_opts.expr = true
    return new_opts
end

-- Neo-tree & Oil
--[[ keymap.set("n", "<Leader>b", function()
    local filetype = vim.bo.filetype
    if filetype == "neo-tree" then
        -- Open oil if we're in neo-tree
        vim.cmd "Neotree close"
        vim.cmd "Oil"
    elseif filetype == "oil" then
        -- Open neo-tree we're in oil
        local current_dir = require("oil").get_current_dir()
        vim.cmd "bdelete"
        vim.cmd.Neotree { args = { ("dir=%s"):format(current_dir or "") } }
    else
        -- Check opened file editor
        local editor_bufnr = nil
        local filetype = nil
        for bufnr, buf in ipairs(vim.bo) do
            local buf_filetype = buf.filetype
            if buf_filetype == "neo-tree" or buf_filetype == "oil" then
                editor_bufnr = bufnr
                filetype = buf_filetype
                break
            end
        end

        -- If no editor is opened, default to neo-tree
        -- If neo-tree is opened, focus
        if not editor_bufnr or filetype == "neo-tree" then
            vim.cmd "Neotree"
            return
        end

        -- TODO: Open oil
    end
end, with_desc(opts, "Switch between neotree and oil")) ]]
keymap.set("n", "<Leader>b", ":Neotree<CR>")

keymap.set({ "n", "v" }, "<C-k>", "<PageUp>", opts)
keymap.set({ "n", "v" }, "<C-j>", "<PageDown>", opts)

keymap.set("i", "<A-h>", "<Left>", opts)
keymap.set("i", "<A-j>", "<Down>", opts)
keymap.set("i", "<A-k>", "<Up>", opts)
keymap.set("i", "<A-l>", "<Right>", opts)

keymap.set("n", "<Leader>h", ":noh<CR>", with_desc(opts, "Clear highlights"))
keymap.set({ "n", "v" }, "<Leader>y", "\"+y", with_desc(opts, "Yank to the system clipboard"))
keymap.set("n", "<Leader>Y", ":let @+=@\"<CR>", with_desc(opts, "Copy \" to system clipboard"))

-- Bufferline
keymap.set("n", "<C-,>", ":BufferLineCyclePrev<CR>", opts)
keymap.set("n", "<C-.>", ":BufferLineCycleNext<CR>", opts)
keymap.set("n", "<C-;>", ":BufferLineMovePrev<CR>", opts)
keymap.set("n", "<C-'>", ":BufferLineMoveNext<CR>", opts)
keymap.set("n", "<Leader>po", ":BufferLinePick<CR>", opts)
keymap.set("n", "<Leader>pc", ":BufferLinePickClose<CR>", opts)

-- Telescope
keymap.set("n", "<Leader>tb", ":Telescope buffers<CR>", opts)
keymap.set("n", "<Leader>tf", ":Telescope find_files<CR>", opts)
keymap.set("n", "<Leader>tg", ":Telescope live_grep<CR>", opts)
keymap.set("n", "<Leader>ta", ":Telescope ast_grep<CR>", opts)
keymap.set("n", "<Leader>ts", ":Telescope treesitter<CR>", opts)
keymap.set("n", "<Leader>td", ":Telescope definitions<CR>", opts)
keymap.set("n", "<Leader>tu", ":Telescope undo<CR>", opts)
keymap.set("n", "<Leader>tr", ":Telescope resume<CR>", with_desc(opts, "Resumes last telescope search"))
keymap.set("n", "<Leader>t/", function()
    local themes = require("telescope.themes")
    require("telescope.builtin").current_buffer_fuzzy_find(themes.get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, opts)
keymap.set("n", "<Leader>ts", function()
    require("auto-session.session-lens").search_session()
end)

-- LSP
keymap.set("n",
    "<Leader>la",
    function() vim.lsp.buf.code_action() end,
    with_desc(opts, "[LSP] Code action"))

keymap.set("n",
    "<Leader>ls",
    function() vim.lsp.buf.hover() end,
    with_desc(opts, "[LSP] Hover"))

keymap.set("n",
    "<Leader>lr",
    function() return ":IncRename " .. vim.fn.expand("<cword>") end,
    with_desc(as_expr(opts), "[LSP] Rename"))

keymap.set("n",
    "<Leader>lf", function() vim.lsp.buf.format() end,
    with_desc(opts, "[LSP] Format"))

keymap.set("n",
    "<Leader>ld",
    function() vim.diagnostic.open_float() end,
    with_desc(opts, "[LSP] Hover diagnostic"))

keymap.set("n",
    "<Leader>lD", function() vim.lsp.buf.declaration() end,
    with_desc(opts, "[LSP] Show declaration"))


keymap.set("n",
    "<Leader>lg",
    function() vim.lsp.buf.definition() end,
    with_desc(opts, "[LSP] Show definition"))

keymap.set("n",
    "<Leader>l,", function() vim.diagnostic.goto_prev() end,
    with_desc(opts, "[LSP] Go to previous diagnostic"))

keymap.set("n",
    "<Leader>l.", function() vim.diagnostic.goto_next() end,
    with_desc(opts, "[LSP] Go to next diagnostic"))

keymap.set("n",
    "<Leader>li",
    function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end,
    with_desc(opts, "[LSP] Toggle inlay hints"))

keymap.set("n",
    "<Leader>lp",
    ":TroubleToggle<CR>",
    with_desc(opts, "[Trouble] Toggle diagnostic view"))

-- LuaSnip
keymap.set({ "i" }, "<C-k>", function()
    local luasnip = require("luasnip")
    luasnip.expand()
end, with_desc(opts, "[LuaSnip] Expand"))

keymap.set({ "i", "s" }, "<C-l>", function()
    local luasnip = require("luasnip")
    luasnip.jump(1)
end, with_desc(opts, "[LuaSnip] Jump forward"))

keymap.set({ "i", "s" }, "<C-h>", function()
    local luasnip = require("luasnip")
    luasnip.jump(-1)
end, with_desc(opts, "[LuaSnip] Jump Backwards"))

keymap.set({ "i", "s" }, "<C-e>", function()
    local luasnip = require("luasnip")
    if luasnip.choice_active() then
        luasnip.change_choice(1)
    end
end, with_desc(opts, "[LuaSnip] Change the current choice"))

-- ccc
keymap.set("n",
    "<Leader>cp",
    ":CccPick<CR>",
    with_desc(opts, "[CCC] Pick color"))

-- venv-selector
keymap.set("n", "<Leader>vs", ":VenvSelect<CR>", with_desc(opts, "Select venv"))

if is_vscode then
    keymap.set("n", "<Leader>w", ":call VSCodeNotify('workbench.action.files.save')<CR>", opts)
else
    keymap.set("n", "<Leader>w", ":w<CR>", opts)
end

-- glance.nvim
keymap.set("n", "gD", "<CMD>Glance definitions<CR>", with_desc(opts, "[Glance] Show definitions"))
keymap.set("n", "gR", "<CMD>Glance references<CR>", with_desc(opts, "[Glance] Show references"))
keymap.set("n", "gY", "<CMD>Glance type_definitions<CR>", with_desc(opts, "[Glance] Show type definitions"))
keymap.set("n", "gM", "<CMD>Glance implementations<CR>", with_desc(opts, "[Glance] Show implementations"))

-- iron.nvim
keymap.set("n", "<Leader>rs", ":IronRepl<CR>", with_desc(opts, "[Iron] Start Iron"))
keymap.set("n", "<Leader>rr", ":IronRestart<CR>", with_desc(opts, "[Iron] Restart Iron"))
keymap.set("n", "<Leader>rf", ":IronFocus<CR>", with_desc(opts, "[Iron] Focus Iron"))

-- TODO: merge with opts
-- keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
