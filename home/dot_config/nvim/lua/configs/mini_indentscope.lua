local M = {}

function M.config()
  local group = vim.api.nvim_create_augroup("conf_mini_indentscope", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
      if #vim.bo.buftype > 0 then
        vim.api.nvim_buf_set_var(0, "miniindentscope_disable", true)
      end
    end
  })

  require"mini.indentscope".setup {
    draw = {
      animation = require"mini.indentscope".gen_animation.none(),
    },
    options = {
      border = "top",
      try_as_border = true,
    },
    symbol = '·',
  }
end

return M
