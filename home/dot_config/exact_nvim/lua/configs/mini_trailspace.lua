function plug.config()
  require'mini.trailspace'.setup()

  vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
    group = vim.api.nvim_create_augroup("conf_mini_trailspace", { clear = true }),
    callback = function()
      MiniTrailspace.trim()
    end
  })
end
