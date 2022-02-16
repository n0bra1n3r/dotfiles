local M = {}

function M.config()
  require"mini.cursorword".setup()
  vim.cmd[[highlight! MiniCursorwordCurrent gui=nocombine guifg=NONE guibg=NONE]]

  require"mini.indentscope".setup {
    draw = {
      animation = require"mini.indentscope".gen_animation("none"),
    },
    options = {
      border = "top",
      try_as_border = true,
    },
    symbol = '·',
  }
end

return M
