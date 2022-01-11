local M = {}

function M.config()
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

  require"lspconfig".nimls.setup {
    capabilities = capabilities,
    cmd = { "cmd", "/c", "nimlsp.cmd" },
    on_attach = function(client, bufnr)
      client.resolved_capabilities.text_document_save = false
    end,
  }
end

return M
