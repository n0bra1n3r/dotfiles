local M = {}

local function open_quickfix()
  vim.cmd(string.format("%dcopen "
    .."| setlocal nonumber "
    .."| wincmd J", math.min(#vim.fn.getqflist(), vim.o.lines / 6)))
end

local function close_quickfix()
  vim.cmd[[cclose]]
end

function M.is_quickfix_visible()
  return #fn.get_wins_for_buf_type("quickfix") > 0
end

function M.toggle_quickfix()
  if not M.is_quickfix_visible() then
    if #vim.fn.getqflist() > 0 then
      open_quickfix()
    end
  else
    close_quickfix()
  end
end

function M.show_quickfix()
  local diagnostics = fn.get_qf_diagnostics()
  if diagnostics.error > 0 or
      diagnostics.warn > 0 or
      diagnostics.hint > 0 then
    open_quickfix()
  end
end

function M.hide_quickfix()
  close_quickfix()
end

function M.next_quickfix()
  open_quickfix()
  vim.cmd[[cnext]]
end

function M.prev_quickfix()
  open_quickfix()
  vim.cmd[[cprev]]
end

return M
