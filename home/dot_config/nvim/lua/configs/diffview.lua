local M = {}

function M.config()
  require"diffview".setup {
    file_panel = {
      win_config = {
        position = "right",
      },
    },
  }
end

return M
