local M = {}

function M.config()
  require"mini.indentscope".setup {
    draw = {
      delay = 100,
      animation = require"mini.indentscope".gen_animation("none"),
    },
    mappings = {
      object_scope = '[]',
      object_scope_with_border = '][',
      goto_top = '[[',
      goto_bottom = ']]',
    },
    symbol = '│',
  }
end

return M
