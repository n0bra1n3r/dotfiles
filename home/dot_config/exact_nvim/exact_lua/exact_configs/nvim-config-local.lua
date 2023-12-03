return {
  config = function()
    require'config-local'.setup {
      config_files = { vim.g.local_config_file_name },
      silent = true,
    }
  end,
}
