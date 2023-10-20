return {
  config = function()
    require'config-local'.setup {
      config_files = { ".nvim/init.lua" },
      lookup_parents = true,
    }
  end,
}
