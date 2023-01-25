local M = {}

function M.config()
  require"auto-session".setup {
    log_level = "error",
  }
end

return M
