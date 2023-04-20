function plug.config()
  local lsp = require'lsp-zero'
  lsp.set_sign_icons {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
  }
  require'lsp-zero.settings'.preset({})
end
