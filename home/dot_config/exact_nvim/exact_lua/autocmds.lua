-- vim: foldmethod=marker foldlevel=0 foldenable

my_autocmds {
  { "BufEnter", --{{{
    callback = function()
      if vim.bo.filetype == "help" then
        if #vim.api.nvim_tabpage_list_wins(0) > 1 then
          vim.cmd.wincmd[[T]]
        end
      elseif vim.bo.filetype == "qf" then
        vim.bo.buflisted = false
      else
        if #vim.bo.buftype == 0 and vim.bo.filetype ~= "toggleterm" then
          vim.api.nvim_set_hl(0, "OverLength", { link = "ColorColumn" })
          if vim.bo.filetype == "gitcommit" then
            vim.cmd[[match OverLength /\%>50v.\+/]]
          else
            vim.cmd[[match OverLength /\%>80v.\+/]]
          end
          vim.wo.number = true
        else
          vim.api.nvim_set_hl(0, "OverLength", {})

          vim.wo.number = false
        end
      end
      vim.cmd[[checktime]]
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
  { "BufWritePre", pattern = "*.dart", --{{{
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
      vim.diagnostic.open_float(nil, { focus = false })
    end,
  }, --}}}
  { "DirChanged", --{{{
    callback = function()
      fn.refresh_git_info()
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
      vim.o.cursorlineopt = "number"
      vim.o.mouse = "nv"
    end
  }, --}}}
  { "FocusLost", --{{{
    callback = function()
      if #vim.bo.buftype == 0 then
        vim.o.cursorlineopt = "both"
      end
      vim.o.mouse = ""
    end
  }, --}}}
  { "TabClosed", --{{{
    callback = function()
      vim.o.cmdheight = 0
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
      fn.show_workspace(nil, false)
    end,
  }, --}}}
  { "TermEnter", --{{{
    callback = fn.vim_defer(function()
      vim.wo.number = false
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
  { "VimEnter", --{{{
    callback = fn.vim_defer(function()
      if vim.env.PARENT_NVIM ~= nil then
        fn.on_child_nvim_enter(
          vim.env.NVIM_CHILD_ID,
          vim.env.PARENT_NVIM)
      end
    end),
  }, --}}}
  { "VimLeavePre", --{{{
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
