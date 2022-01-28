local M = {}

function M.setup()
  vim.cmd[[augroup conf_asyncrun]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd User AsyncRunPre cclose | lua fn.set_is_job_in_progress(true)]]
  vim.cmd[[autocmd User AsyncRunStop lua fn.show_quickfix() ; fn.set_is_job_in_progress(false)]]
  vim.cmd[[augroup end]]

  vim.g.asyncrun_rootmarks = {}
  vim.g.asyncrun_runner = {
    project_runner = function(opts)
      fn.run_process(opts.cmd, opts.post)
    end,
    debug_runner = function(opts)
      fn.run_command(opts.cmd)
    end,
  }
end

return M
