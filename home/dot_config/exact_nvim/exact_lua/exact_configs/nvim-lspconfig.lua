local function goto_definition(win_cmd)
  return function()
    vim.lsp.buf.definition {
      on_list = function(options)
        if options.items then
          if #options.items > 1 then
            fn.update_lsp_definitions_list(options)
            fn.show_lsp_definitions_list()
          else
            if win_cmd then
              vim.cmd(win_cmd)
            end
            local item = options.items[1]
            vim.cmd.drop(item.filename)
            vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
          end
        end
      end,
      reuse_win = true,
    }
  end
end

local function format()
  vim.lsp.buf.format()
end

return {
  config = function()
    local lsp = require'lsp-zero'

    lsp.on_attach(function(_, bufnr)
      local function map(m, lhs, rhs, desc)
        vim.api.nvim_buf_set_keymap(bufnr, m, lhs, [[]], {
          callback = rhs,
          desc = desc,
          noremap = true,
        })
      end

      map('n', 'K', vim.lsp.buf.hover)
      map('n', 'gd', goto_definition(), "Go to definition")
      map('n', '<C-w><C-f>', goto_definition('vsplit'), "Go to definition in vertical split")
      map('n', '<C-w>f', goto_definition('split'), "Go to definition in split")
      map('n', '<C-w>gf', goto_definition('tab split'), "Go to definition in new tab")
      map('n', 'gR', vim.lsp.buf.references, "Show symbol references")
      map('n', '<F2>', vim.lsp.buf.rename)
      map('n', '<F3>', format)
      map('x', '<F3>', format)
      map('n', '<F4>', vim.lsp.buf.code_action)

      if vim.lsp.buf.range_code_action then
        map('x', '<F4>', vim.lsp.buf.range_code_action)
      else
        map('x', '<F4>', vim.lsp.buf.code_action)
      end

      map('n', '[s', vim.diagnostic.goto_prev, "Go to next diagnostic")
      map('n', ']s', vim.diagnostic.goto_next, "Go to previous diagnostic")
    end)

    vim.diagnostic.config(lsp.defaults.diagnostics {
      signs = false,
      update_in_insert = false,
      virtual_text = false,
    })

    local config = require'lspconfig'
    local default_config = function(name)
      local is_ok, module = pcall(require, 'lspconfig.server_configurations.'..name);
      return is_ok and module.default_config
    end

    require'mason-lspconfig'.setup {
      ensure_installed = {
        'bashls',
        'graphql',
        'jsonls',
        'kotlin_language_server',
        'lua_ls',
        'marksman',
        'pyright',
      },
      handlers = {
        function(server)
          config[server].setup{}
        end,
        lua_ls = function()
          config.lua_ls.setup(lsp.nvim_lua_ls {
            root_dir = function(fname)
              if fname:match('/%.nvim/init%.lua$') then
                return vim.fn.expand'~/.config/nvim/lua'
              else
                ---@diagnostic disable-next-line: undefined-field
                return default_config'lua_ls'.root_dir(fname)
              end
            end,
          })
        end,
      },
    }

    config.sourcekit.setup {
      cmd = {
        'xcrun',
        '--toolchain',
        'swift',
        'sourcekit-lsp',
      },
    }

    local nim_lsp_client_id

    require'lspconfig.configs'.nim_lsp = {
      default_config = {
        cmd = require'nim_lsp'.cmd(function()
          return nim_lsp_client_id
        end),
        filetypes = { 'nim' },
        on_init = function(client)
          nim_lsp_client_id = client.id
        end,
        root_dir = function()
          return vim.fn.getcwd()
        end,
      },
    }

    config.nim_lsp.setup{}

    lsp.setup()
  end,
}
