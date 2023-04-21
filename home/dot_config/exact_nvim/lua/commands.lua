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
