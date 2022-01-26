local M = {}

function M.setup()
  vim.g.floaterm_autoinsert = 0
  vim.g.floaterm_height = 0.3
end

function M.config()
  vim.cmd[[augroup conf_floaterm]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd VimLeavePre * FloatermKill!]]
  vim.cmd[[augroup end]]

  vim.cmd("FloatermNew --silent "
    .."--name=git_shell "
    .."--title=git "
    .."--height=0.8 "
    .."--width=0.8 "
    .."bash --rcfile ~/.dotfiles/gitrc")

  vim.cmd("FloatermNew --silent "
    .."--name=run_shell "
    .."--title=run "
    .."--wintype=split "
    .."--height=0.3 "
    .."bash --rcfile ~/.dotfiles/runrc")
end

return M
