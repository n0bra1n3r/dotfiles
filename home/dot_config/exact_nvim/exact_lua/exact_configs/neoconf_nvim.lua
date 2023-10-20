return {
  config = function()
    require'neoconf'.setup {
      global_settings = '.neoconf.json',
      import = {
        vscode = false,
        coc = false,
        nlsp = false,
      },
      live_reload = false,
      filetype_jsonc = true,
      plugins = {
        lspconfig = {
          enabled = true,
        },
        jsonls = {
          enabled = true,
          configured_servers_only = true,
        },
        lua_ls = {
          enabled_for_neovim_config = true,
          enabled = false,
        },
      },
    }
  end,
}
