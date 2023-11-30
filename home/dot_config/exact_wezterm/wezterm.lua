local wezterm = require'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Catppuccin Frappe'
local color_scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
config.font = wezterm.font{ family = 'Hasklug Nerd Font', weight = 'Medium' }
config.font_size = 15.0
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.initial_cols = 220
config.initial_rows = 60
config.keys = {
  {
    key = 'Enter',
    mods = 'CTRL',
    action = wezterm.action.SendString'\x1b[13;5u',
  },
  {
    key = 'Tab',
    mods = 'CTRL',
    action = wezterm.action.SendString'\x1b[9;5u',
  },
}
config.scrollback_lines = 9001
config.window_frame = {
  font_size = config.font_size,
  active_titlebar_bg = color_scheme.background,
  inactive_titlebar_bg = color_scheme.background,
}
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

return config
