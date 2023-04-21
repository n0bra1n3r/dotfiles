function plug.config()
  vim.b.minicursorword_disable = #vim.bo.buftype > 0

  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("conf_mini_cursorword", { clear = true }),
    callback = fn.vim_defer(function()
      vim.b.minicursorword_disable = #vim.bo.buftype > 0
    end),
  })

  require'mini.cursorword'.setup()
end
