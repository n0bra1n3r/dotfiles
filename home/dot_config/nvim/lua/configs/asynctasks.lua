local M = {}

function M.setup()
  vim.g.asynctasks_config_name = ".tasks.ini"
  vim.g.asynctasks_extra_config = {
    "~/.config/nvim/tasks/global.ini",
  }

  if fn.is_git_dir() then
    vim.g.asynctasks_profile = "project"
  else
    vim.g.asynctasks_profile = "file"
  end

  vim.g.asynctasks_template = "~/.config/nvim/tasks/template.ini"
  vim.g.asynctasks_term_focus = 0
  vim.g.asynctasks_term_reuse = 1
end

return M
