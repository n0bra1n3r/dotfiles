function plug.config()
  local lsp = require'lsp-zero'

  require'lsp-zero.settings'.preset{}

  vim.diagnostic.config(require'lsp-zero'.defaults.diagnostics {
    underline = false,
    virtual_text = false,
  })

  lsp.set_sign_icons {
    error = config.signs.DiagnosticSignError.text,
    hint = config.signs.DiagnosticSignHint.text,
    info = config.signs.DiagnosticSignInfo.text,
    warn = config.signs.DiagnosticSignWarn.text,
  }
end
