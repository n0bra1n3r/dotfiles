local M = {}

function M.get_qf_diagnostic_list()
  local diagnostics = {}
  for _, value in ipairs(vim.fn.getqflist()) do
    local diagnostic = {
      bufnr = value.bufnr,
      lnum = value.lnum - 1,
      end_lnum = value.end_lnum - 1,
      col = value.col,
      end_col = value.end_col,
      message = value.text,
      source = "quickfix",
      code = value.nr
    }
    if value.type == "E" then
      diagnostic.severity = vim.diagnostic.severity.ERROR
    elseif value.type == "N" then
      diagnostic.severity = vim.diagnostic.severity.HINT
    elseif value.type == "W" then
      diagnostic.severity = vim.diagnostic.severity.WARN
    end

    if diagnostic.severity ~= nil then
      table.insert(diagnostics, diagnostic)
    end
  end
  return diagnostics
end

function M.set_qf_diagnostics()
  local namespace = vim.api.nvim_create_namespace("qf-diagnostics")
  local buf_diagnostics = {}

  for _, diagnostic in ipairs(M.get_qf_diagnostic_list()) do
    local buf_key = diagnostic.bufnr

    if buf_diagnostics[buf_key] == nil then
      buf_diagnostics[buf_key] = {}
    end

    table.insert(buf_diagnostics[buf_key], diagnostic)
  end

  for buf_key, diagnostics in pairs(buf_diagnostics) do
    vim.diagnostic.set(namespace, buf_key, diagnostics)
  end
end

return M
