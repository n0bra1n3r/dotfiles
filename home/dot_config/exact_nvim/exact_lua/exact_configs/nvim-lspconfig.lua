return {
  config = function()
    local lsp = require'lsp-zero'
    lsp.on_attach(function(_, bufnr)
      vim.diagnostic.config(require'lsp-zero'.defaults.diagnostics {
        severity_sort = true,
        signs = false,
        virtual_text = {
          format = function()
            return [[]]
          end,
          prefix = '',
          spacing = 1,
        },
      })

      local function map(m, lhs, rhs)
        vim.api.nvim_buf_set_keymap(bufnr, m, lhs, [[]], {
          callback = rhs,
          noremap = true,
        })
      end

      map('n', 'K', vim.lsp.buf.hover)
      map('n', 'gd', vim.lsp.buf.definition)
      map('n', 'gD', vim.lsp.buf.declaration)
      map('n', 'gi', vim.lsp.buf.implementation)
      map('n', 'go', vim.lsp.buf.type_definition)
      map('n', 'gr', vim.lsp.buf.references)
      map('n', 'gs', vim.lsp.buf.signature_help)
      map('n', '<F2>', vim.lsp.buf.rename)
      map('n', '<F3>', function() vim.lsp.buf.format{ async = true } end)
      map('x', '<F3>', function() vim.lsp.buf.format{ async = true } end)
      map('n', '<F4>', vim.lsp.buf.code_action)

      if vim.lsp.buf.range_code_action then
        map('x', '<F4>', vim.lsp.buf.range_code_action)
      else
        map('x', '<F4>', vim.lsp.buf.code_action)
      end

      map('n', 'gl', vim.diagnostic.open_float)
      map('n', '[d', vim.diagnostic.goto_prev)
      map('n', ']d', vim.diagnostic.goto_next)
    end)

    local config = require'lspconfig'

    require'mason-lspconfig'.setup({
      ensure_installed = {
        'bashls',
        'lua_ls',
        'pyright',
      },
      handlers = {
        function(server)
          config[server].setup{}
        end,
        lua_ls = function()
          config.lua_ls.setup(lsp.nvim_lua_ls())
        end,
      }
    })

    config.nim_langserver.setup {
      -- settings = {
      --   nim = {
      --     autoCheckFile = false,
      --     autoCheckProject = false,
      --   },
      -- },
    }

    lsp.setup()
  end,
}
