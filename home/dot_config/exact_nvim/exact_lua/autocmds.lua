-- vim: fcl=all fdm=marker fdl=0 fen

my_autocmds {
  { 'BufEnter', --{{{
    callback = function()
      vim.cmd[[checktime]]
    end,
  }, --}}}
  { "BufEnter", pattern = "*.arb", --{{{
    callback = function()
      vim.bo.filetype = "json"
    end,
  }, --}}}
  { "BufEnter", pattern = { '*.podspec', 'fastlane/*', 'Podfile' }, --{{{
    callback = function()
      vim.bo.filetype = 'ruby'
    end,
  }, --}}}
  { { 'BufEnter', 'BufWinEnter' }, --{{{
    callback = function()
      if #vim.bo.buftype == 0 then
        if vim.bo.filetype == 'gitcommit' then
          vim.cmd.match[[OverLength /\%>50v.\+/]]
        else
          vim.cmd.match[[OverLength /\%>80v.\+/]]
        end

        vim.wo.foldcolumn = '1'
        vim.wo.number = true
      else
        vim.cmd.match[[OverLength //]]

        vim.wo.foldcolumn = '0'
        vim.wo.number = false
      end
    end,
  }, --}}}
  { "BufHidden", --{{{
    callback = function()
      if fn.is_empty_buffer() then
        vim.bo.buflisted = false
      end
    end,
  }, --}}}
  { "BufUnload", --{{{
    callback = function(args)
      fn.del_buf_from_loclist(args.buf)
      if fn.is_file_buffer(args.buf) then
        if fn.has_workspace_file() then
          fn.save_workspace()
        end
      end
    end,
  }, --}}}
  { "BufWinLeave", --{{{
    callback = function(args)
      fn.add_buf_to_loclist(args.buf)
      if fn.is_file_buffer(args.buf) then
        if fn.has_workspace_file() then
          fn.save_workspace()
        end
      end
    end,
  }, --}}}
  { 'BufWinEnter', --{{{
    callback = function()
      if fn.is_file_buffer()
          and not fn.is_empty_buffer()
          and fn.has_workspace_file() then
        fn.save_workspace()
      else
        if vim.bo.filetype == 'help' then
          if #vim.api.nvim_tabpage_list_wins(0) > 1 then
            vim.cmd.wincmd[[T]]
          end
        elseif vim.bo.filetype == 'qf' then
          if #vim.api.nvim_tabpage_list_wins(0) > 1 then
            vim.cmd.wincmd[[J]]
          end
        elseif vim.bo.filetype == 'dap-repl' then
          vim.api.nvim_buf_attach(0, false, {
            on_lines = function()
              local last_line = vim.fn.line('$')
              if vim.fn.line('w$') >= last_line - 1 then
                local buf = vim.api.nvim_get_current_buf()
                local win = vim.fn.bufwinid(buf)
                vim.api.nvim_win_call(win, function()
                  vim.api.nvim_win_set_cursor(win, { last_line, 0 })
                end)
              end
            end
          })
        end
      end
    end,
  }, --}}}
  { "BufWritePre", pattern = { '*.dart', '*.json' }, --{{{
    callback = function()
      vim.lsp.buf.format()
    end,
  }, --}}}
  { "CmdlineEnter", --{{{
    callback = function()
      vim.o.cmdheight = 1
    end,
  }, --}}}
  { "CmdlineLeave", --{{{
    callback = function()
      vim.o.cmdheight = 0
    end,
  }, --}}}
  { "CmdWinEnter", --{{{
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[$l<C-c>]],
        { noremap = true })
    end,
  }, --}}}
  { "CursorHold", --{{{
    callback = function()
      for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(winid).zindex then
          return
        end
      end
      vim.diagnostic.open_float {
        close_events = {
          "CursorMoved",
          "CursorMovedI",
          "BufHidden",
          "InsertCharPre",
          "WinLeave",
        },
        focusable = false,
        scope = "cursor",
      }
    end,
  }, --}}}
  { "DirChanged", --{{{
    callback = function()
      fn.refresh_git_info()

      pcall(vim.api.nvim_del_keymap, 'n', [[<leader>pr]])
    end,
  }, --}}}
  { "FileType", pattern = { "diff", "gitcommit", "gitrebase" }, --{{{
    callback = function()
      vim.bo.bufhidden = "wipe"
    end,
  }, --}}}
  { "FileType", pattern = "help", --{{{
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[<cmd>quit<CR>]],
        { noremap = true, silent = true })
    end,
  }, --}}}
  { "FileType", pattern = "qf", --{{{
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[<cmd>close<CR>]],
        { noremap = true, silent = true })
    end,
  }, --}}}
  { 'FileType', pattern = 'search', --{{{
    callback = function()
      require'ufo'.detach()
    end,
  }, --}}}
  { 'FocusGained', --{{{
    callback = function()
      fn.apply_focused_highlight()

      vim.o.cursorlineopt = "number"

      fn.vim_defer(function()
        for _, mode in ipairs({ 'c', 'i', 'n', 'x' }) do
          pcall(vim.api.nvim_del_keymap, mode, [[<LeftMouse>]])
        end
      end, vim.o.timeoutlen)()
    end
  }, --}}}
  { "FocusLost", --{{{
    callback = function()
      fn.apply_unfocused_highlight()

      if #vim.bo.buftype == 0 then
        vim.o.cursorlineopt = "both"
      end

      for _, mode in ipairs({ 'c', 'i', 'n', 'x' }) do
        vim.api.nvim_set_keymap(mode, [[<LeftMouse>]], [[]], {
          callback = function() end,
          noremap = true,
        })
      end
    end
  }, --}}}
  { "TabClosed", --{{{
    callback = function()
      vim.o.cmdheight = 0
      fn.restore_tabpage()
    end,
  }, --}}}
  { "TabEnter", --{{{
    callback = function()
      fn.sync_terminal()
      fn.show_workspace()
    end,
  }, --}}}
  { "TabLeave", --{{{
    callback = function()
      fn.save_tabpage()
      fn.show_workspace(nil, false)

      if vim.fn.reg_recording() ~= '' then
        vim.cmd[[normal q]]
        fn.vim_defer(function()
          vim.notify("Stopped macro recording")
        end)()
      end
    end,
  }, --}}}
  { 'TermEnter', --{{{
    callback = fn.vim_defer(function()
      vim.cmd.match[[OverLength //]]
      vim.cmd[[nohlsearch]]
    end),
  }, --}}}
  { "TextYankPost", --{{{
    callback = function()
      vim.highlight.on_yank {
        higroup = "IncSearch",
        timeout = 200,
      }
    end,
  }, --}}}
  { "User", pattern = "ConfigLocalFinished", --{{{
    callback = function()
      if fn.has_local_config() then
        if vim.g.project_type then
          local project_config = vim.g.project_configs[vim.g.project_type]
          if project_config then
            vim.api.nvim_set_keymap("n", [[<leader>pr]], [[]], {
              callback = function()
                fn.open_tab(project_config)
              end,
              desc = "Project",
              noremap = true,
              silent = true,
            })
          end
          fn.load_vscode_launch_json()
        end
      end
    end,
  }, --}}}
  { "VimLeavePre", --{{{
    callback = function()
      vim.cmd[[cclose]]
    end,
  }, --}}}
}
