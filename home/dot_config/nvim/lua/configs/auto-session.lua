local M = {}

function M.config()
  require"auto-session".setup {
    auto_session_use_git_branch = true,
    log_level = "error",
  }
end

return M
