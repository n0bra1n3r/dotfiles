-- vim: foldmethod=marker foldlevel=0 foldenable

my_autocmds {
  { "BufEnter", --{{{
    callback = function()
      vim.cmd[[match OverLength //]]

      if vim.bo.filetype == "help" then
        if #vim.api.nvim_tabpage_list_wins(0) > 1 then
          vim.cmd.wincmd[[T]]
        end
      elseif vim.bo.filetype == "qf" then
        vim.bo.buflisted = false
      else
        if fn.is_file_buffer() then
          if vim.bo.filetype == "gitcommit" then
            vim.cmd[[match OverLength /\%>50v.\+/]]
          else
            vim.cmd[[match OverLength /\%>80v.\+/]]
          end
          vim.wo.number = true
        else
          vim.wo.number = false
        end
      end
      vim.cmd[[checktime]]
    end,
  }, --}}}
  { "BufEnter", pattern = "*.arb", --{{{
    callback = function()
      vim.bo.filetype = "json"
    end,
  }, --}}}
  { "BufEnter", pattern = "fastlane/*", --{{{
    callback = function()
      vim.bo.filetype = "ruby"
    end,
  }, --}}}
  { "BufEnter", pattern = "Podfile", --{{{
    callback = function()
      vim.bo.filetype = "ruby"
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
  { "BufWinEnter", --{{{
    callback = function()
      if fn.is_file_buffer() then
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

      if vim.fn.maparg([[<leader>pr>]], 'n', 0, 1).rhs ~= nil then
        vim.api.nvim_del_keymap('n', [[<leader>pr]])
      end
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
  { "FocusGained", --{{{
    callback = function()
      fn.apply_focused_highlight()

      vim.o.cursorlineopt = "number"

      fn.vim_defer(function()
        for _, mode in ipairs({ 'c', 'i', 'n', 'x' }) do
          vim.api.nvim_del_keymap(mode, [[<LeftMouse>]])
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
    end,
  }, --}}}
  { "TermEnter", --{{{
    callback = fn.vim_defer(function()
      vim.wo.number = false
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
    end,
  }, --}}}
  { "VimLeavePre", --{{{
    callback = function()
      vim.cmd[[cclose]]
    end,
  }, --}}}
}
