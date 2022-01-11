local M = {}

function M.config()
  require"diffview".setup {
    file_panel = {
      position = "right",
    },
  }
end

return M
