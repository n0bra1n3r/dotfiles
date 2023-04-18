-- vim: foldmethod=marker foldlevel=0 foldenable

commands {
  G = { --{{{
    function(opts)
      fn.send_terminal("git "..opts.args)
      fn.open_terminal()
    end,
    complete = function(lead)
      local pipe = io.popen("bash -c 'git-complete.bash "..lead.."'")
      local completions = pipe:read("*a")
      pipe:close()
      return vim.fn.split(completions, "\n")
    end,
    desc = "Git command",
    nargs = "+",
  }, --}}}
}
