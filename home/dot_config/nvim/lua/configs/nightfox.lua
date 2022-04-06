local M = {}

function M.config()
  require"nightfox".setup {
    options = {
      dim_inactive = true,
    },
  }

  vim.cmd[[colorscheme nordfox]]
end

return M
