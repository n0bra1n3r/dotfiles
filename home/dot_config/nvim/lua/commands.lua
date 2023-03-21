-- vim: foldmethod=marker foldlevel=0 foldenable

commands {
  G = { -- {{{
    function(opts)
      fn.open_terminal("git "..opts.args)
    end,
    bang = true,
    complete = function(lead)
      local script = "git-complete.bash"
      local pipe = io.popen("bash -c '"..script.." "..lead.."'")
      local completions = pipe:read("*a")
      pipe:close()
      return vim.fn.split(completions, "\n")
    end,
    desc = "Run git command",
    nargs = "+",
  }, --}}}
}
