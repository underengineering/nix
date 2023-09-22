local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- config.font = wezterm.font "Fira Code"
-- config.font_size = 11

config.font = wezterm.font "Iosevka"
config.font_size = 12
config.harfbuzz_features = {
    "ss14",   -- JetBrains Mono
    "cv45=1", -- u
    "cv95=2", -- ~
    "cv99=1", -- ()
    "VSAA=1", -- {}
    "VLAA=1", -- >=
}

config.color_scheme = "Gruvbox dark, medium (base16)"

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

local color_scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
config.colors = {
    tab_bar = {
        background = color_scheme.background,
        active_tab = {
            fg_color = "#b8b226",
            bg_color = "#3c3836",
            intensity = "Bold",
        },
        inactive_tab = {
            fg_color = color_scheme.foreground,
            bg_color = color_scheme.background,
        },
        inactive_tab_hover = {
            fg_color = color_scheme.foreground,
            bg_color = "#3c3836",
            italic = true,
        },
        new_tab = {
            bg_color = "#3c3836",
            fg_color = color_scheme.foreground,
        },
        new_tab_hover = {
            bg_color = "#504945",
            fg_color = color_scheme.foreground,
            italic = true,
        }
    }
}

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

local BACKGROUND_PATH = "/home/mika/projects/temp/"
local backgrounds = { "astolfo_dark", "vanilla_dark", "chocola_dark", "natsuki_joy" }
local autism_enabled = false
local background_idx = 1
config.keys[#config.keys + 1] = {
    mods = "CTRL|SHIFT",
    key = "B",
    action = wezterm.action.EmitEvent "bg-toggle"
}
wezterm.on("bg-toggle", function(window, pane)
    autism_enabled = not autism_enabled

    local config_overrides = {}
    if autism_enabled then
        config_overrides.window_background_image = BACKGROUND_PATH .. backgrounds[background_idx] .. ".png"
    else
        config_overrides.window_background_image = nil
    end

    window:set_config_overrides(config_overrides)
end)
config.keys[#config.keys + 1] = {
    mods = "CTRL|SHIFT",
    key = "N",
    action = wezterm.action.EmitEvent "bg-next"
}
wezterm.on("bg-next", function(window, pane)
    background_idx = background_idx + 1
    if background_idx > #backgrounds then
        background_idx = 1
    end

    local config_overrides = {}
    if autism_enabled then
        config_overrides.window_background_image = BACKGROUND_PATH .. backgrounds[background_idx] .. ".png"
    else
        config_overrides.window_background_image = nil
    end

    window:set_config_overrides(config_overrides)
end)

config.set_environment_variables = {
    WSLENV = "TERMINFO_DIRS",
}
config.term = "wezterm"

return config
