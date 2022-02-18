local M = {}

function M.setup()
  vim.g.floaterm_height = 0.3
  vim.g.floaterm_opener = "tabe"
end

function M.config()
  vim.cmd[[augroup conf_floaterm]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd FileType floaterm nnoremap <buffer><silent> <Esc> <cmd>FloatermHide<CR>]]
  vim.cmd[[autocmd VimLeavePre * FloatermKill!]]
  vim.cmd[[augroup end]]
end

return M
