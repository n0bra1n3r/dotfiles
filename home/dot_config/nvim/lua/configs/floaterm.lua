local M = {}

function M.setup()
  vim.g.asyncrun_rootmarks = {}
end

function M.config()
  vim.cmd[[FloatermNew --silent --name=git_shell --title=git bash --rcfile ~/.dotfiles/gitrc]]
end

return M
