local M = {}

function project_runner(opts)
  local exit_msg = "[Process exited with code $?]"

  vim.cmd(string.format("FloatermSend --name=run_shell %s ; echo -e \\\\n%s\\\\n", opts.cmd, exit_msg))
  local floaterm_autoinsert = vim.g.floaterm_autoinsert
  vim.cmd[[FloatermShow run_shell]]
  vim.cmd("file "..opts.cmd)
  vim.cmd[[$]]
end

function M.setup()
  vim.g.asyncrun_rootmarks = {}
  vim.g.asyncrun_runner = {
    project_runner = project_runner,
  }
end

return M
