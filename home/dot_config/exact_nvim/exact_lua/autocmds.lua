-- vim: fcl=all fdm=marker fdl=0 fen

my_autocmds {
  { { 'BufEnter', 'BufWinEnter', 'FileType' }, --{{{
    callback = function()
      vim.cmd.checktime()

      if #vim.bo.buftype == 0 then
        if vim.bo.filetype == 'gitcommit' then
          vim.cmd.match[[OverLength /\%>50v.\+/]]
        else
          vim.cmd.match[[OverLength /\%>80v.\+/]]
        end
      else
        vim.cmd.match[[OverLength //]]
      end
    end,
  }, --}}}
  { { 'BufEnter', 'BufWinEnter' }, pattern = "*.arb", --{{{
    callback = function()
      vim.bo.filetype = "json"
    end,
  }, --}}}
  { { 'BufEnter', 'BufWinEnter' }, pattern = { '*.podspec', 'fastlane/*', 'Podfile' }, --{{{
    callback = function()
      vim.bo.filetype = 'ruby'
    end,
  }, --}}}
  { 'BufHidden', --{{{
    callback = function()
      if fn.is_empty_buffer() then
        vim.bo.buflisted = false
      end
    end,
  }, --}}}
  { "BufUnload", --{{{
    callback = function(args)
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
        elseif vim.bo.filetype == 'dap-repl' then
          vim.api.nvim_buf_attach(0, false, {
            on_lines = function()
              if not vim.wo.wrap then
                local last_line = vim.fn.line('$')
                if vim.fn.line('w$') >= last_line - 1 then
                  local buf = vim.api.nvim_get_current_buf()
                  local win = vim.fn.bufwinid(buf)
                  vim.api.nvim_win_call(win, function()
                    vim.api.nvim_win_set_cursor(win, { last_line, 0 })
                  end)
                end
              end
            end
          })
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
  { "BufWritePre", pattern = { '*.dart', '*.json', '*.kt', '*.nim', '*.swift' }, --{{{
    callback = function()
      vim.lsp.buf.format()
    end,
  }, --}}}
  { "BufWritePost", pattern = { '.nvim/init.lua' }, --{{{
    callback = function()
      vim.g.flutter_current_config = nil
      vim.g.flutter_current_device = nil
    end,
  }, --}}}
  { "CmdlineEnter", --{{{
    callback = function()
      vim.o.cmdheight = 1
    end,
  }, --}}}
  { { 'CmdlineEnter', 'CmdWinEnter', 'InsertEnter', 'TermEnter' }, --{{{
    callback = function()
      fn.vim_defer(vim.cmd.nohlsearch)()
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
  { { 'CursorMoved', 'InsertEnter' }, --{{{
    callback = function()
      vim.wo.relativenumber = false
    end,
  }, --}}}
  { 'DiagnosticChanged', --{{{
    callback = function()
      fn.update_lsp_diagnostics_list()
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
  { 'FileType', pattern = 'nim', --{{{
    callback = function()
      vim.cmd.filetype{ args = { 'plugin', 'off' } }
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
      fn.show_workspace()
    end,
  }, --}}}
  { "TabLeave", --{{{
    callback = function()
      fn.save_tabpage()
      fn.show_workspace(nil, false)

      if vim.fn.reg_recording() ~= '' then
        vim.cmd.normal[[q]]
        fn.vim_defer(function()
          vim.notify("Stopped macro recording")
        end)()
      end
    end,
  }, --}}}
  { "TextYankPost", --{{{
    callback = function()
      vim.highlight.on_yank {
        higroup = "IncSearch",
        timeout = 200,
      }
    end,
  }, --}}}
  { 'User', pattern = 'ConfigLocalFinished', --{{{
    callback = function()
      if fn.has_workspace_config() then
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

          if vim.g.project_type == 'flutter' then
            vim.api.nvim_set_keymap('n', [[<leader>fa]], [[]], {
              callback = function()
                fn.open_in_os{ './android', '-a', '/Applications/Android Studio.app' }
                vim.notify(
                  "Opening Android project...",
                  vim.log.levels.INFO,
                  { title = "Flutter tools" }
                )
              end,
              desc = "Open Android project",
              noremap = true,
              silent = true,
            })
            vim.api.nvim_set_keymap('n', [[<leader>fi]], [[]], {
              callback = function()
                if vim.fn.isdirectory('./ios/Runner.xcworkspace') == 1 then
                  fn.open_in_os{ './ios/Runner.xcworkspace' }
                  vim.notify(
                    "Opening iOS project...",
                    vim.log.levels.INFO,
                    { title = "Flutter tools" }
                  )
                else
                  vim.notify(
                    "No workspace folder found!",
                    vim.log.levels.WARN,
                    { title = "Flutter tools" }
                  )
                end
              end,
              desc = "Open iOS project",
              noremap = true,
              silent = true,
            })
          elseif vim.g.project_type == 'chezmoi' then
            vim.api.nvim_set_keymap('n', [[<leader>fc]], [[]], {
              callback = function()
                fn.open_in_os{ vim.fn.expand'~/.config/nvim' }
              end,
              desc = "Open config folder",
              noremap = true,
              silent = true,
            })
          end
        end
      end
    end,
    once = true,
  }, --}}}
  { 'WinEnter', --{{{
    callback = function()
      if vim.bo.filetype == 'dap-repl' then
        vim.wo.wrap = true
      end
    end,
  }, --}}}
  { 'WinLeave', --{{{
    callback = function()
      if vim.bo.filetype == 'dap-repl' then
        vim.wo.wrap = false
      elseif vim.bo.filetype == 'qf' then
        fn.save_lsp_diagnostics_pos()
      end
    end,
  }, --}}}
}
