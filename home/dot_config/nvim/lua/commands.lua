-- vim: foldmethod=marker foldlevel=0 foldenable

commands {
  G = { -- {{{
    function(opts)
      fn.open_terminal("git "..opts.args)
    end,
    bang = true,
    nargs = "+",
  }, --}}}
}
