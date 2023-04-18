function plug.init()
  vim.g.asynctasks_config_name = ".nvim/tasks.ini"
  vim.g.asynctasks_extra_config = {
    "~/.config/nvim/tasks/global.ini",
  }
  vim.g.asynctasks_template = "~/.config/nvim/tasks/template.ini"
  vim.g.asynctasks_term_focus = 0
  vim.g.asynctasks_term_reuse = 1
end
