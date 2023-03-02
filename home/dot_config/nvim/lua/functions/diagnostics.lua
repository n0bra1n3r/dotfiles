local M = {}

function M.get_qf_diagnostics()
  local error_count = 0
  local hint_count = 0
  local warn_count = 0
  for _, value in ipairs(vim.fn.getqflist()) do
    if value.type == "E" then
      error_count = error_count + 1
    elseif value.type == "N" then
      hint_count = hint_count + 1
    elseif value.type == "W" then
      warn_count = warn_count + 1
    end
  end
  return { error = error_count, hint = hint_count, warn = warn_count }
end


function M.set_qf_diagnostics()
  local namespace = vim.api.nvim_create_namespace("qf-diagnostics")
  local buf_diagnostics = {}

  for _, diagnostic in ipairs(vim.diagnostic.fromqflist(vim.fn.getqflist())) do
    local buf_key = diagnostic.bufnr

    if buf_diagnostics[buf_key] == nil then
      buf_diagnostics[buf_key] = {}
    end

    table.insert(buf_diagnostics[buf_key], diagnostic)
  end

  vim.diagnostic.reset(namespace)

  for buf_key, diagnostics in pairs(buf_diagnostics) do
    vim.diagnostic.set(namespace, buf_key, diagnostics)
  end
end

return M
