-- vim: fcl=all fdm=marker fdl=0 fen

my_commands {
  InitTerminalMode = { --{{{
    function()
      fn.init_terminal_mode()
    end,
    desc = "Init terminal mode",
  }, --}}}
  W = "WorkspaceOpen",
  Ws = "WorkspaceSave",
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
