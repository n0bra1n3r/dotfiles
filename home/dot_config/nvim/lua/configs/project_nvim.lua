local M = {}

function M.config()
  require"project_nvim".setup {
    detection_methods = { "pattern" },
    patterns = { ".git" },
  }
end

return M
