-- vim: foldmethod=marker foldlevel=0 foldenable

my_globals {
  grapple_testing = true, -- needed to avoid error on Windows
  mapleader = [[ ]],
  project_configs = {
    chezmoi = 'home/dot_config/exact_nvim/exact_lua/plugins.lua',
    flutter = 'pubspec.yaml',
  },
  project_filetypes = {
    chezmoi = 'lua',
    flutter = 'dart',
  },
  workspace_file_name = '.nvim/workspace.vim',
}
