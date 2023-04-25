function plug.config()
  local lsp = require'lsp-zero'
  lsp.on_attach(function(_, bufnr)
    lsp.default_keymaps { buffer = bufnr }
  end)

  local config = require'lspconfig'

  config.lua_ls.setup(lsp.nvim_lua_ls())

  local shellslash = vim.o.shellslash
  vim.o.shellslash = false
  local nim_server_path = vim.fn.expand"~/.nimble/bin/nimlangserver.cmd"
  vim.o.shellslash = shellslash

  config.nimls.setup {
    cmd = { nim_server_path },
    on_new_config = function(new_config, new_root_dir)
      new_config.rootUri = ([[file://%s]]):format(new_root_dir)
    end,
    root_dir = function(filename)
      return config.util.root_pattern[[*.nimble]](filename) or
        config.util.root_pattern[[config.nims]](filename) or
        config.util.root_pattern[[*.nims]](filename) or
        config.util.root_pattern[[.nvim]](filename) or
        config.util.root_pattern[[.git]](filename) or
        config.util.root_pattern[[main.nim]](filename) or
        config.util.root_pattern[[*.nim]](filename)
    end,
  }

  lsp.setup()
end
