-- vim: foldmethod=marker foldlevel=0 foldenable

commands {
  G = { --{{{
    function(opts)
      fn.send_terminal("git "..fn.expand_each(opts.fargs))
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
  Ga = { --{{{
    function(opts)
      fn.send_terminal("git add -p "..fn.expand_each(opts.fargs))
      fn.open_terminal()
    end,
    complete = function(lead)
      return config.commands.G.complete("add -p "..lead)
    end,
    desc = "Git add files",
    nargs = "?",
  }, --}}}
  H = "Help",
  HelpModeStart = {
    function(opts)
      vim.cmd("help "..opts.args)
      vim.cmd[[set laststatus=0|tabonly]]
    end,
    desc = "Start help mode",
    nargs = "?",
  },
  Help = { --{{{
    function(opts)
      fn.open_help(opts.args or [[]])
    end,
    complete = function(lead)
      return vim.fn.getcompletion(lead, "help")
    end,
    desc = "Open help",
    nargs = "?",
  }, --}}}
  W = "WorkspaceOpen",
  TerminalModeStart = { --{{{
    function()
      fn.open_terminal()
      vim.cmd[[tabonly]]
    end,
    desc = "Start terminal mode",
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
      for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
        local cwd = vim.fn.getcwd(-1, tabnr)
        if cwd:find(lead) ~= nil
            and vim.fn.getcwd(-1) ~= cwd
            and not fn.is_workspace_frozen(tabnr) then
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
