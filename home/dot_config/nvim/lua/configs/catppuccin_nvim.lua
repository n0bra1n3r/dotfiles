local M = {}

function M.config()
  require'catppuccin'.setup {
    flavour = "mocha",
    dim_inactive = {
      enabled = true,
    },
  }

  vim.cmd[[colorscheme catppuccin]]
end

return M
