function plug.init()
  vim.g.asynctasks_config_name = ".nvim/tasks.ini"
  vim.g.asynctasks_extra_config = {
    vim.env.MYVIMRC.."/tasks/global.ini",
  }
  vim.g.asynctasks_template = vim.env.MYVIMRC.."/tasks/template.ini"
  vim.g.asynctasks_term_focus = 0
  vim.g.asynctasks_term_reuse = 1
end
