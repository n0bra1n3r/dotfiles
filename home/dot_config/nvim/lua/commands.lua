local M = {}

M.G = {
  function(opts)
    fn.open_shell("git "..opts.args)
  end,
  bang = true,
  nargs = "+",
}

return M
