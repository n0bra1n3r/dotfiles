return {
  G = {
    function(opts)
      fn.open_terminal("git "..opts.args)
    end,
    bang = true,
    nargs = "+",
  },
}
