function plug.config()
  local lsp = require'lsp-zero'
  lsp.on_attach(function(_, bufnr)
    lsp.default_keymaps { buffer = bufnr }
  end)

  local config = require'lspconfig'

  config.lua_ls.setup(lsp.nvim_lua_ls())

  config.nimls.setup {
    cmd = { fn.expand_path"~/.nimble/bin/nimlangserver.cmd" },
    on_new_config = function(new_config, new_root_dir)
      new_config.rootUri = ([[file://%s]]):format(new_root_dir)
    end,
    root_dir = function(filename)
      return config.util.root_pattern[[*.nimble]](filename) or
        config.util.root_pattern[[config.nims]](filename) or
        config.util.root_pattern[[*.cfg]](filename) or
        config.util.root_pattern[[*.nimcfg]](filename) or
        config.util.root_pattern[[*.nims]](filename) or
        config.util.root_pattern[[.nvim]](filename) or
        config.util.root_pattern[[.git]](filename) or
        config.util.root_pattern[[main.nim]](filename) or
        config.util.root_pattern[[*.nim]](filename)
    end,
    settings = {
      checkOnSave = false,
      autoCheckFile = false,
      autoCheckProject = false,
    },
  }

  lsp.setup()
end
