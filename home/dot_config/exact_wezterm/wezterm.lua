local wezterm = require'wezterm'

wezterm.on('user-var-changed', function(window, _, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == 'font_family' then
    name = 'font'
    value = wezterm.font{ family = value }
  end
  overrides[name] = value
  window:set_config_overrides(overrides)
end)

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Catppuccin Frappe'
local color_scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
config.font = wezterm.font{ family = 'Lilex Nerd Font', weight = 'Medium' }
config.font_size = 15.0
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
  font_size = config.font_size - 2,
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
