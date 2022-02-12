local M = {}

function M.config()
  require"nightfox".setup {
    alt_nc = true,
    fox = "nordfox",
    inverse = {
      visual = true,
    },
    transparent = false,
  }

  require"nightfox".load()
end

return M
