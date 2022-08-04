local M = {}

function M.get_map_expr(key)
  return string.format("v:count || mode(1)[0:1] == 'no' ? '%s' : 'g%s'", key, key)
end

function M.vim_defer(fn, timer)
  return function()
    if fn ~= nil then
      if type(fn) == "function" then
        vim.defer_fn(fn, timer or 0)
      else
        vim.defer_fn(function()
          vim.cmd(fn)
        end, timer or 0)
      end
    end
  end
end

return M
