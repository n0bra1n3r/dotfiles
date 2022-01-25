local M = {}

function M.setup()
  vim.g.asynctasks_config_name = ".tasks.ini"
  vim.g.asynctasks_template = "~/.config/nvim/tasks/task_template.ini"
  vim.g.asynctasks_term_focus = 0
  vim.g.asynctasks_term_reuse = 1
end

return M
