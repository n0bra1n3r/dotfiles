local M = {}

function M.get_qf_diagnostic_list()
  return vim.diagnostic.fromqflist(vim.fn.getqflist())
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
