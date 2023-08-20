local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- config.font = wezterm.font "Fira Code"
-- config.font_size = 11

config.font = wezterm.font "Iosevka"
config.font_size = 12
config.harfbuzz_features = {
    "ss14",   -- JetBrains Mono
    "cv92=1", -- ()
    "cv93=1", -- {}
    "cv45=1", -- u
    "VXLA=1", -- >=
}

config.color_scheme = "Gruvbox dark, medium (base16)"

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
}

local function is_on_ac()
    for _, battery in ipairs(wezterm.battery_info()) do
        if battery.state == "Discharging" then
            return false
        end
    end

    return true
end

if is_on_ac() then
    config.default_cursor_style = "BlinkingBar"
    config.cursor_blink_rate = 800
    config.cursor_blink_ease_in = "Constant"
    config.cursor_blink_ease_out = "Constant"
else
    config.default_cursor_style = "SteadyBar"
end

config.window_background_opacity = 0.8

config.ssh_domains = {
    {
        name = "parsemyx.ml",
        remote_address = "185.106.92.119",
        username = "mika"
    }
}

config.keys = {
    {
        mods = "CTRL|SHIFT",
        key = "s",
        action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
    },
    {
        mods = "CTRL|SHIFT",
        key = "d",
        action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }
    },
    {
        mods = "CTRL|SHIFT",
        key = "w",
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },
    {
        mods = "CTRL|SHIFT",
        key = "<",
        action = wezterm.action.ActivateTabRelative(-1)
    },
    {
        mods = "CTRL|SHIFT",
        key = ">",
        action = wezterm.action.ActivateTabRelative(1)
    },
    {
        mods = "CTRL|SHIFT",
        key = ":",
        action = wezterm.action.MoveTabRelative(-1)
    },
    {
        mods = "CTRL|SHIFT",
        key = "\"",
        action = wezterm.action.MoveTabRelative(1)
    },
}

config.set_environment_variables = {
    WSLENV = "TERMINFO_DIRS",
}
config.term = "wezterm"

return config
