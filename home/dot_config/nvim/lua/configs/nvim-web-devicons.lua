local M = {}

function M.config()
  require"nvim-web-devicons".setup {
    override = {
      nim = {
        icon = '',
        color = "orange",
        name = "Nim",
      },
      nimble = {
        icon = '',
        color = "orange",
        name = "Nimble",
      },
      nims = {
        icon = '',
        color = "orange",
        name = "NimScript",
      },
    },
  }
end

return M
