local M = {}

function M.config()
  require"auto-session".setup {
    auto_restore_enabled = true,
    auto_save_enabled = true,
    log_level = "error",
    pre_save_cmds = {
      fn.cleanup_session,
    },
  }
end

return M
