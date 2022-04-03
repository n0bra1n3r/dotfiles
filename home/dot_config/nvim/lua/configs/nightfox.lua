local M = {}

function M.config()
  require"nightfox".setup {
    options = {
      dim_inactive = true,
      inverse = {
        match_paren = true,
      },
    },
  }

  vim.cmd[[colorscheme nordfox]]
end

return M
