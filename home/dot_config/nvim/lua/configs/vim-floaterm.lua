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
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", [[<cmd>FloatermHide<CR>]],
        { noremap = true, silent = true })
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function()
      if vim.bo.filetype == "floaterm" then
        vim.cmd[[FloatermHide]]
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    command = [[FloatermKill!]],
  })
end

return M
