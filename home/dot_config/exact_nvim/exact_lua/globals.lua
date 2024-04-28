-- vim: fcl=all fdm=marker fdl=0 fen

my_globals {
  local_config_file_name = '.nvim/init.lua',
  mapleader = [[ ]],
  project_configs = {
    chezmoi = 'home/dot_config/exact_nvim/exact_lua/plugins.lua',
    flutter = 'pubspec.yaml',
  },
  project_filetypes = {
    chezmoi = 'lua',
    flutter = 'dart',
  },
  project_icons = {
    flutter = '',
    nim = '󰆥',
  },
  workspace_file_name = '.nvim/workspace.vim',
}
