return {
  G = {
    function(opts)
      fn.open_shell("git "..opts.args)
    end,
    bang = true,
    nargs = "+",
  },
}
