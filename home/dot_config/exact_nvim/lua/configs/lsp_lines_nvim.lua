local diagnostic_timer

local function disable_diagnostic_display()
  vim.diagnostic.config{ virtual_lines = false }

  if diagnostic_timer ~= nil then
    diagnostic_timer:close()
    diagnostic_timer = nil
  end
end

local function display_diagnostics_soon()
  if diagnostic_timer ~= nil then
    diagnostic_timer:close()
    diagnostic_timer = nil
  end

  diagnostic_timer = vim.loop.new_timer()
  diagnostic_timer:start(1000, 0, vim.schedule_wrap(function()
    vim.diagnostic.config{ virtual_lines = { only_current_line = true } }
    diagnostic_timer:close()
    diagnostic_timer = nil
  end))
end

local function has_lsp()
  local bufnr = vim.api.nvim_get_current_buf()
  return #vim.lsp.get_active_clients{ bufnr = bufnr } > 0
end

function plug.config()
  require'lsp_lines'.setup()

  vim.diagnostic.config(require'lsp-zero'.defaults.diagnostics {
    virtual_text = false,
  })

  local group = vim.api.nvim_create_augroup("lsp_lines_conf", { clear = true })
  local prev_line
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function()
      if has_lsp() then
        local line = vim.api.nvim_get_current_line()
        if prev_line ~= nil and prev_line ~= line then
          disable_diagnostic_display()
          display_diagnostics_soon()
        end
        prev_line = line
      end
    end,
  })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      if has_lsp() then
        disable_diagnostic_display()
      end
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      if has_lsp() then
        display_diagnostics_soon()
      end
    end,
  })
end
