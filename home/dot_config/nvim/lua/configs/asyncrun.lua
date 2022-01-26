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
  vim.cmd[[augroup conf_asyncrun]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd User AsyncRunPre cclose | lua fn.set_is_job_in_progress(true)]]
  vim.cmd[[autocmd User AsyncRunStop lua fn.show_quickfix() ; fn.set_is_job_in_progress(false)]]
  vim.cmd[[augroup end]]

  vim.g.asyncrun_rootmarks = {}
  vim.g.asyncrun_runner = {
    project_runner = project_runner,
  }
end

return M
