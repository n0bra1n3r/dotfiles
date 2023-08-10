function plug.config()
  local lsp = require'lsp-zero'

  require'lsp-zero.settings'.preset {
    float_border = "single",
  }

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
end
