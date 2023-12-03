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

local color_scheme = 'Catppuccin Frappe'
local color_scheme_inactive = 'Catppuccin Macchiato'
local text_font = { family = 'JetBrainsMono Nerd Font', weight = 'Medium' }

local scheme = wezterm.color.get_builtin_schemes()[color_scheme]
local scheme_inactive = wezterm.color.get_builtin_schemes()[color_scheme_inactive]

config.color_scheme = color_scheme
config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = scheme.background,
      fg_color = scheme.foreground,
    },
    inactive_tab = {
      bg_color = scheme_inactive.background,
      fg_color = scheme_inactive.split,
    },
    inactive_tab_edge = scheme.foreground,
    inactive_tab_hover = {
      bg_color = scheme_inactive.background,
      fg_color = scheme.foreground,
    },
    new_tab = {
      bg_color = scheme.background,
      fg_color = scheme_inactive.split,
    },
    new_tab_hover = {
      bg_color = scheme.background,
      fg_color = scheme.foreground,
    },
  },
}
config.font = wezterm.font(text_font)
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
  active_titlebar_bg = scheme_inactive.background,
  inactive_titlebar_bg = scheme_inactive.background,
}
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

return config
