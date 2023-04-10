local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font "Fira Code"
config.font_size = 11
config.color_scheme = "Gruvbox dark, medium (base16)"

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

return config
