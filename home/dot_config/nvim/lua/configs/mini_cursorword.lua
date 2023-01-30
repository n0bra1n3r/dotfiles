local M = {}

function M.config()
  local group = vim.api.nvim_create_augroup("conf_mini_cursorword", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "*",
    callback = function()
      if #vim.bo.buftype > 0 then
        vim.api.nvim_buf_set_var(0, "minicursorword_disable", true)
      end
    end
  })

  require"mini.cursorword".setup()
end

return M
