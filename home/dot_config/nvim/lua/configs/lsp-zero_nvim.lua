function plug.config()
  local lsp = require'lsp-zero'.preset {}
  lsp.on_attach(function(_, bufnr)
    lsp.default_keymaps { buffer = bufnr }
  end)
  require'lspconfig'.lua_ls.setup(lsp.nvim_lua_ls {
    cmd = {
      "bash",
      "-c",
      (
        '"%s/.dotfiles/lua-language-server/bin/lua-language-server.exe"'
        ..' --configpath'
        ..' "%s/.dotfiles/luarc.lua"'
      ):format(vim.fn.expand[[~]], vim.fn.expand[[~]]),
    },
  })
  lsp.set_sign_icons {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
  }
  lsp.setup()
end
