local M = {}

function M.config()
  require"mini.trailspace".setup()

  local group = vim.api.nvim_create_augroup("conf_mini_trailspace", { clear = true })

  vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
    group = group,
    pattern = "*",
    callback = function()
      MiniTrailspace.trim()
    end
  })
end

return M
