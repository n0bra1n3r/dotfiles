local M = {}

function M.init()
  local group = vim.api.nvim_create_augroup("conf_asyncrun", { clear = true })

  local should_show_quickfix

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "AsyncRunStart",
    callback = function()
      should_show_quickfix = fn.is_quickfix_visible()
      if should_show_quickfix then
        fn.hide_quickfix()
      end
      fn.set_is_job_in_progress(true)
    end
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "AsyncRunStop",
    callback = function()
      fn.set_qf_diagnostics()
      fn.set_is_job_in_progress(false)
      if should_show_quickfix then
        fn.show_quickfix()
      end
    end
  })

  vim.g.asyncrun_rootmarks = {}
end

return M
