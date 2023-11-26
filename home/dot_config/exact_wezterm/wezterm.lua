local wezterm = require'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Catppuccin Frappe'
config.font = wezterm.font('JetBrainsMono NF', { weight = 'Medium' })
config.font_size = 15
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
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

return config
