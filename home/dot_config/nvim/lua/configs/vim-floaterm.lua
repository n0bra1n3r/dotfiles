local M = {}

function M.init()
  vim.g.floaterm_autoinsert = false
  vim.g.floaterm_opener = "tabe"
end

function M.config()
  local group = vim.api.nvim_create_augroup("conf_floaterm", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "floaterm",
    command = [[nnoremap <buffer><silent> <Esc> <cmd>FloatermHide<CR>]],
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    pattern = "floaterm",
    callback = function()
      local win_config = vim.api.nvim_win_get_config(0)
      if win_config.relative ~= "" then
        vim.cmd[[FloatermHide]]
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    pattern = "*",
    command = [[FloatermKill!]],
  })
end

return M
