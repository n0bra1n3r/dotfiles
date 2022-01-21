local M = {}

function M.config()
  require"nightfox".setup {
    alt_nc = true,
    fox = "nordfox",
    inverse = {
      match_paren = true,
      visual = true,
      search = true,
    },
  }

  require"nightfox".load()
end

return M
