function plug.init()
  local rc_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ":h")

  vim.g.asynctasks_config_name = ".nvim/tasks.ini"
  vim.g.asynctasks_extra_config = {
    rc_dir.."/tasks/global.ini",
  }
  vim.g.asynctasks_template = rc_dir.."/tasks/template.ini"
  vim.g.asynctasks_term_focus = 0
  vim.g.asynctasks_term_reuse = 1
end
