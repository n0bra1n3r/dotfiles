local M = {}

function M.config()
  require"auto-session".setup {
    auto_restore_enabled = true,
    auto_save_enabled = true,
    log_level = "error",
  }
end

return M
