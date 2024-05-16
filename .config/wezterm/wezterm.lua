local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Visuals
config.color_scheme = "Catppuccin Mocha"
config.cursor_blink_rate = 0

-- Tabs
config.hide_tab_bar_if_only_one_tab = true

return config
