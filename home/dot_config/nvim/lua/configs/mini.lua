local M = {}

function M.config()
  vim.cmd[[autocmd FileType * if len(&buftype) > 0 | let b:miniindentscope_disable=v:true | endif]]
  vim.cmd[[autocmd FileType * if len(&buftype) > 0 | let b:minicursorword_disable=v:true | endif]]

  require"mini.cursorword".setup()

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
