local M = {}

local function preview_location_callback(_, result, ctx)
  if result == nil or vim.tbl_isempty(result) then
    vim.lsp.log.info(ctx, "No location found")
    return nil
  end

  if vim.tbl_islist(result) then
    vim.lsp.util.preview_location(result[1])
  else
    vim.lsp.util.preview_location(result)
  end
end

function M.peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
end

local prev_line

function M.trigger_completion()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2]

  local before_line = string.sub(line, 1, cursor + 1)
  local after_line = string.sub(line, cursor + 1, -1)

  if prev_line == nil or #prev_line < #before_line then
    if string.len(after_line) == 0 and (
      string.match(before_line, "[%w%.]%w$") or
      string.match(before_line, "[%.]$")) then
      require"cmp".complete()
    else
      require"cmp".close()
    end
  else
    require"cmp".close()
  end

  prev_line = before_line
end

function M.end_completion()
  require"cmp".close()
end

return M
