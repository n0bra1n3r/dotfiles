function plug.config()
  local lsp = require'lsp-zero'
  lsp.on_attach(function(_, bufnr)
    local function fmt(cmd)
      return function(str)
        return cmd:format(str)
      end
    end

    local lspfn = fmt('<cmd>lua vim.lsp.%s<cr>')
    local diagfn = fmt('<cmd>lua vim.diagnostic.%s<cr>')

    local function map(m, lhs, rhs)
      vim.api.nvim_buf_set_keymap(bufnr, m, lhs, rhs, { noremap = true })
    end

    map('n', 'K', lspfn'buf.hover()')
    map('n', 'gd', lspfn'buf.definition()')
    map('n', 'gD', lspfn'buf.declaration()')
    map('n', 'gi', lspfn'buf.implementation()')
    map('n', 'go', lspfn'buf.type_definition()')
    map('n', 'gr', lspfn'buf.references()')
    map('n', 'gs', lspfn'buf.signature_help()')
    map('n', '<F2>', lspfn'buf.rename()')
    map('n', '<F3>', lspfn'buf.format{ async = true }')
    map('x', '<F3>', lspfn'buf.format{ async = true }')
    map('n', '<F4>', lspfn'buf.code_action()')

    if vim.lsp.buf.range_code_action then
      map('x', '<F4>', lspfn'buf.range_code_action()')
    else
      map('x', '<F4>', lspfn'buf.code_action()')
    end

    map('n', 'gl', diagfn'open_float()')
    map('n', '[d', diagfn'goto_prev()')
    map('n', ']d', diagfn'goto_next()')
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
      -- We are using null-ls for checking.
      checkOnSave = false,
      autoCheckFile = false,
      autoCheckProject = false,
    },
  }

  local efm_yaml = {
    {
      lintCommand = "actionlint -no-color -oneline -",
      lintFormats = {
        '%f:%l:%c: %m',
      },
      lintStdin = true,
      rootMarkers = { ".github/" },
    },
  }

  config.efm.setup {
    settings = {
      languages = {
        yaml = efm_yaml,
      },
    }
  }

  lsp.setup()
end
