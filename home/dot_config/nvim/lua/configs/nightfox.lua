local M = {}

function M.config()
  require"nightfox".setup {
    alt_nc = true,
    fox = "nordfox",
    inverse = {
      visual = true,
    },
    transparent = true,
  }

  require"nightfox".load()
end

return M
