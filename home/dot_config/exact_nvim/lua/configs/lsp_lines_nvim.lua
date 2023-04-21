function plug.config()
  require'lsp_lines'.setup()

  vim.diagnostic.config(require'lsp-zero'.defaults.diagnostics {
    virtual_lines = {
      only_current_line = true,
    },
    virtual_text = false,
  })
end
