local M = {}

function M.config()
  require"mini.indentscope".setup {
    draw = {
      animation = require"mini.indentscope".gen_animation("none"),
    },
    symbol = '·',
  }
end

return M
