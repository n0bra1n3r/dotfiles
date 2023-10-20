return {
  config = function()
    require'mini.trailspace'.setup()

    vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
      group = vim.api.nvim_create_augroup("conf_mini_trailspace", { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].filetype ~= "diff" then
          MiniTrailspace.trim()
        end
      end
    })
  end,
}
