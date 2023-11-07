-- vim: fcl=all fdm=marker fdl=0 fen

my_commands {
  G = { --{{{
    function(opts)
      fn.send_terminal("git "..fn.expand_each(opts.fargs), false, not opts.bang)
    end,
    bang = true,
    complete = function(lead)
      local pipe = io.popen("bash -c 'git-complete.bash "..lead.."'")
      local completions = pipe:read("*a")
      pipe:close()
      return vim.fn.split(completions, "\n")
    end,
    desc = "Git command",
    nargs = "+",
  }, --}}}
  Ga = { --{{{
    function(opts)
      fn.send_terminal("git add -p "..fn.expand_each(opts.fargs))
    end,
    complete = function(lead)
      return my_config.commands.G.complete("add -p "..lead)
    end,
    desc = "Git add files",
    nargs = "?",
  }, --}}}
  W = "WorkspaceOpen",
  Ws = "WorkspaceSave",
  TerminalModeStart = { --{{{
    function(opts)
      fn.refresh_git_info()
      fn.set_terminal_dir()
      vim.cmd[[tabonly]]
      if opts.args and #opts.args > 0 then
        fn.send_terminal(opts.args.." && clear")
      end
    end,
    desc = "Start terminal mode",
    nargs = "?",
  }, --}}}
  WorkspaceFreeze = { --{{{
    function()
      fn.freeze_workspace()
    end,
    desc = "Freeze workspace",
  }, --}}}
  WorkspaceOpen = { --{{{
    function(opts)
      fn.open_workspace(opts.args)
    end,
    complete = function(lead)
      local completions = {}
      local cur_cwd = fn.get_tab_cwd()
      for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        local cwd = fn.get_tab_cwd(tabpage)
        if cwd:find(lead) ~= nil and cur_cwd ~= cwd
            and not fn.is_workspace_frozen(tabpage) then
          table.insert(completions, vim.fn.fnamemodify(cwd, ":~"))
        end
      end
      if #vim.trim(lead) ~= 0 or #completions == 0 then
        completions = vim.fn.extend(completions, vim.fn.getcompletion(lead, "dir"))
      end
      return completions
    end,
    desc = "Open workspace",
    nargs = 1,
  }, --}}}
  WorkspaceSave = { --{{{
    function()
      fn.save_workspace(nil, true)
    end,
    desc = "Save workspace",
  }, --}}}
}
