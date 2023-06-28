-- vim: foldmethod=marker foldlevel=0 foldenable

my_autocmds {
  BufEnter = {
    { pattern = "*", --{{{
      callback = function()
        vim.cmd[[checktime]]
      end,
    }, --}}}
    { pattern = "dart", --{{{
      callback = function()
        vim.b.debug_restart_cmd = "FlutterRestart"
        vim.b.debug_start_cmd = "FlutterRun"
        vim.b.debug_stop_cmd = "FlutterQuit"
      end,
    }, --}}}
    { pattern = "help", --{{{
      callback = function()
        if #vim.api.nvim_tabpage_list_wins(0) > 1 then
          vim.cmd.wincmd[[T]]
        end
      end,
    }, --}}}
    { pattern = "qf", --{{{
      callback = function()
        vim.bo.buflisted = false
      end,
    }, --}}}
  },
  BufHidden = { --{{{
    callback = function(args)
      if fn.is_empty_buffer(args.buf) then
        vim.bo[args.buf].buflisted = false
      end
    end,
  }, --}}}
  BufUnload = {
    callback = function(args)
      fn.del_buf_from_loclist(args.buf)
      if fn.is_file_buffer(args.buf) then
        if fn.has_workspace_file() then
          fn.save_workspace()
        end
      end
    end,
  },
  BufWinEnter = { --{{{
    callback = function(args)
      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        if #vim.bo[args.buf].buftype == 0 then
          if #vim.bo[args.buf].filetype == "gitcommit" then
            vim.wo[win].colorcolumn = "51,73"
          else
            vim.wo[win].colorcolumn = "81,120"
          end
          vim.wo[win].number = true
        else
          vim.wo[win].colorcolumn = nil
          vim.wo[win].number = false
        end
      end
      if fn.is_file_buffer(args.buf) then
        if fn.has_workspace_file() then
          fn.save_workspace()
        end
      end
    end,
  }, --}}}
  BufWinLeave = { --{{{
    callback = function(args)
      fn.add_buf_to_loclist(args.buf)
      if fn.is_file_buffer(args.buf) then
        if fn.has_workspace_file() then
          fn.save_workspace()
        end
      end
    end,
  }, --}}}
  BufWritePost = { --{{{
    callback = function(args)
      fn.project_check()
    end,
  }, --}}}
  CmdlineEnter = { --{{{
    callback = function()
      vim.o.cmdheight = 1
    end,
  }, --}}}
  CmdlineLeave = { --{{{
    callback = function()
      vim.o.cmdheight = 0
    end,
  }, --}}}
  CmdWinEnter = { --{{{
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[$l<C-c>]],
        { noremap = true })
    end,
  }, --}}}
  CursorHold = { --{{{
    callback = function()
      vim.diagnostic.open_float(nil, { focus = false })
    end,
  }, --}}}
  DirChanged = { --{{{
    callback = function()
      fn.refresh_git_info()
    end,
  }, --}}}
  FileType = {
    { pattern = { "diff", "gitcommit", "gitrebase" }, --{{{
      callback = function()
        vim.bo.bufhidden = "wipe"
      end,
    }, --}}}
    { pattern = "help", --{{{
      callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[<cmd>quit<CR>]],
          { noremap = true, silent = true })
      end,
    }, --}}}
    { pattern = "qf", --{{{
      callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[<cmd>close<CR>]],
          { noremap = true, silent = true })
      end,
    }, --}}}
  },
  FocusGained = {
    callback = function()
      vim.o.cursorlineopt = "number"
      vim.o.mouse = "nv"
    end
  },
  FocusLost = {
    callback = function()
      if #vim.bo.buftype == 0 then
        vim.o.cursorlineopt = "both"
      end
      vim.o.mouse = ""
    end
  },
  TabClosed = { --{{{
    callback = function()
      vim.o.cmdheight = 0
      fn.pop_to_previous_tab()
    end,
  }, --}}}
  TabEnter = { --{{{
    callback = function()
      fn.sync_terminal()
      fn.show_workspace()
    end,
  }, --}}}
  TabLeave = { --{{{
    callback = function()
      fn.show_workspace(nil, false)
    end,
  }, --}}}
  TermEnter = { --{{{
    callback = fn.vim_defer(function()
      vim.wo.colorcolumn = nil
      vim.wo.number = false
    end),
  }, --}}}
  TextYankPost = { --{{{
    callback = function()
      vim.highlight.on_yank {
        higroup = "IncSearch",
        timeout = 200,
      }
    end,
  }, --}}}
  VimEnter = { --{{{
    callback = fn.vim_defer(function()
      if vim.env.PARENT_NVIM ~= nil then
        fn.on_child_nvim_enter(
          vim.env.NVIM_CHILD_ID,
          vim.env.PARENT_NVIM)
      end
      fn.refresh_git_info()
    end),
  }, --}}}
  VimLeavePre = { --{{{
    callback = function()
      if vim.env.PARENT_NVIM ~= nil then
        fn.on_child_nvim_exit(
          vim.env.NVIM_CHILD_ID,
          vim.env.PARENT_NVIM)
      end
      vim.cmd[[cclose]]
    end,
  }, --}}}
}
