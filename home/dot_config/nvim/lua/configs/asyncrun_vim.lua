local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("conf_asyncrun", { clear = true })

  local cur_win

  vim.api.nvim_create_autocmd("User", {
    pattern = "AsyncRunStart",
    callback = function()
      vim.cmd[[cclose]]
      fn.set_is_job_in_progress(true)
      cur_win = vim.api.nvim_get_current_win()
    end
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "AsyncRunStop",
    callback = function()
      local focus_win = vim.api.nvim_get_current_win()
      if cur_win ~= nil and vim.api.nvim_win_is_valid(cur_win) then
        vim.api.nvim_set_current_win(cur_win)
      end
      fn.show_quickfix()
      fn.set_qf_diagnostics()
      vim.api.nvim_set_current_win(focus_win)
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
