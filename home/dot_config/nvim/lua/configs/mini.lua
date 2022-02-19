local M = {}

function M.config()
  require"mini.cursorword".setup()

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
