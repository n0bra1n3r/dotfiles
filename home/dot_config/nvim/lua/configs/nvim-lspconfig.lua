function plug.config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.did_save = false
  capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }

  require'lspconfig'.nimls.setup {
    capabilities = capabilities,
    cmd = { "cmd", "/c", "nimlsp.cmd" },
    on_attach = function(client, bufnr)
      client.server_capabilities.textDocumentSync.save = false

      vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", [[]], {
        callback = vim.lsp.buf.definition,
        noremap = true,
        silent = true,
        desc = "Go to definition",
      })
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ld", [[]], {
        callback = vim.lsp.buf.definition,
        noremap = true,
        silent = true,
        desc = "Go to definition",
      })
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lh", [[]], {
        callback = vim.lsp.buf.hover,
        noremap = true,
        silent = true,
        desc = "Show hover",
      })
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lr", [[]], {
        callback = vim.lsp.buf.rename,
        noremap = true,
        silent = true,
        desc = "Rename symbol",
      })
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ls", [[]], {
        callback = vim.lsp.buf.references,
        noremap = true,
        silent = true,
        desc = "Show references",
      })
    end,
  }
end
