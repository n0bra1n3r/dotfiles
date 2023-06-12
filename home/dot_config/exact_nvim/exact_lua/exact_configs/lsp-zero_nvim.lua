function plug.config()
  local lsp = require'lsp-zero'

  require'lsp-zero.settings'.preset {
    float_border = "single",
  }

  vim.diagnostic.config(require'lsp-zero'.defaults.diagnostics {
    severity_sort = true,
    signs = false,
    virtual_text = {
      format = function(_) return "" end,
      spacing = 1,
    },
  })

  lsp.set_sign_icons {
    error = my_config.signs.DiagnosticSignError.text,
    hint = my_config.signs.DiagnosticSignHint.text,
    info = my_config.signs.DiagnosticSignInfo.text,
    warn = my_config.signs.DiagnosticSignWarn.text,
  }
end
