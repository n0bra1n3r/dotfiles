local M = {}

function M.config()
  require'flutter-tools'.setup {
    ui = {
      border = "single",
    },
  }
end

return M
