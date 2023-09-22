return function()
    local dashboard = require("alpha.themes.dashboard")
    dashboard.section.header.val = {
        [[                                                                       ]],
        [[                                                                     ]],
        [[       ████ ██████           █████      ██                     ]],
        [[      ███████████             █████                             ]],
        [[      █████████ ███████████████████ ███   ███████████   ]],
        [[     █████████  ███    █████████████ █████ ██████████████   ]],
        [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
        [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
        [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
        [[                                                                       ]],
    }

    dashboard.section.buttons.val = {
        dashboard.button("n", "  > [N]ew file", ":ene | startinsert<CR>"),
        -- dashboard.button("f", "󰈞  > Find file", ":cd $HOME/Workspace | Telescope find_files<CR>"),
        -- dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
        -- dashboard.button("s", "  > Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
        dashboard.button("s", "  > Find [s]ession", ":lua require('auto-session.session-lens').search_session()<CR>"),
        dashboard.button("q", "󰅚  > [Q]uit", ":qa<CR>")
    }

    vim.api.nvim_create_autocmd("User", {
        once = true,
        callback = function()
            local startup_time = require("lazy.stats").stats().startuptime
            dashboard.section.footer.val = ("Startup time: %.2fms"):format(startup_time)
        end,
        pattern = "LazyVimStarted"
    })

    require("alpha").setup(dashboard.opts)
end
