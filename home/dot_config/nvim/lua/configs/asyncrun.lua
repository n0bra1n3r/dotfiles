local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("conf_asyncrun", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "AsyncRunStart",
    callback = function()
      vim.cmd[[cclose]]
      fn.set_is_job_in_progress(true)
    end
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "AsyncRunStop",
    callback = function()
      fn.show_quickfix()
      fn.set_qf_diagnostics()
      fn.set_is_job_in_progress(false)
    end
  })

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
