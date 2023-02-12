local M = {}

function M.config()
  require'cmp_tabnine.config':setup {
    max_lines = 1,
    max_num_results = 3,
  }
end

return M
