local M = {}

function M.init()
  local group = vim.api.nvim_create_augroup("conf_asyncrun", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "AsyncRunStart",
    callback = function()
      fn.set_is_job_in_progress(true)
    end
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "AsyncRunStop",
    callback = function()
      fn.set_qf_diagnostics()
      fn.set_is_job_in_progress(false)
    end
  })

  vim.g.asyncrun_rootmarks = {}
end

return M
