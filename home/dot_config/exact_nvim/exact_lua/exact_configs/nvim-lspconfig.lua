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

      local function map(m, lhs, rhs, desc)
        vim.api.nvim_buf_set_keymap(bufnr, m, lhs, [[]], {
          callback = rhs,
          desc = desc,
          noremap = true,
        })
      end

      map('n', 'K', vim.lsp.buf.hover)
      map('n', 'gR', vim.lsp.buf.references, "List symbol references")
      map('n', '<F2>', vim.lsp.buf.rename)
      map('n', '<F3>', function() vim.lsp.buf.format{ async = true } end)
      map('x', '<F3>', function() vim.lsp.buf.format{ async = true } end)
      map('n', '<F4>', vim.lsp.buf.code_action)

      if vim.lsp.buf.range_code_action then
        map('x', '<F4>', vim.lsp.buf.range_code_action)
      else
        map('x', '<F4>', vim.lsp.buf.code_action)
      end

      map('n', '[s', vim.diagnostic.goto_prev, "Go to next diagnostic")
      map('n', ']s', vim.diagnostic.goto_next, "Go to previous diagnostic")
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

    config.sourcekit.setup{}

    lsp.setup()
  end,
}
