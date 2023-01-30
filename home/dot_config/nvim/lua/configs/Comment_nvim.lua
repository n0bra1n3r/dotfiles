local M = {}

function M.config()
  require"Comment".setup()
  require"Comment.ft".nim = { "#%s", "#[%s]#" }
end

return M
