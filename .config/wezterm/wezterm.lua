local wezterm = require("wezterm")

return {
  -- Visuals
  color_scheme = "Catppuccin Mocha",
  cursor_blink_rate = 0,

  -- Tabs
  hide_tab_bar_if_only_one_tab = true,

  -- No title bar needed
  window_decorations = "RESIZE",

  keys = {
    -- Make Shift+Enter work in zellij
    {
      key = 'Enter',
      mods = 'SHIFT',
      action = wezterm.action.SendString("\x1b[200~\n\x1b[201~"),
    },
  }
}
