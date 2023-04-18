-- vim: foldmethod=marker foldlevel=0 foldenable

commands {
  G = { --{{{
    function(opts)
      local args = {}
      for _, arg in ipairs(opts.fargs) do
        table.insert(args, vim.fn.expand(arg))
      end
      fn.send_terminal("git "..vim.fn.join(args))
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
