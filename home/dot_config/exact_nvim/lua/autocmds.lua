-- vim: foldmethod=marker foldlevel=0 foldenable

autocmds {
  BufEnter = { --{{{
    callback = function()
      if fn.is_empty_buffer() then
        vim.bo.bufhidden = "delete"
      elseif fn.has_workspace_file() then
        fn.save_workspace()
      end
      vim.cmd[[checktime]]
      fn.set_qf_diagnostics()
    end,
  }, --}}}
  BufFilePre = { --{{{
    callback = function()
      if fn.is_empty_buffer() then
        vim.bo.bufhidden = nil
      end
    end,
  }, --}}}
  BufWinEnter = { --{{{
    callback = function()
      if #vim.bo.buftype == 0 then
        vim.wo.colorcolumn = "81,120"
        vim.wo.number = true
      else
        vim.wo.colorcolumn = nil
        vim.wo.number = false
      end
    end,
  }, --}}}
  BufWritePost = { --{{{
    callback = function()
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
  DirChanged = { --{{{
    callback = function()
      fn.refresh_git_info()
    end,
  }, --}}}
  FileType = {
    { pattern = "diff", --{{{
      callback = function()
        vim.bo.bufhidden = "wipe"
        vim.bo.textwidth = 72
      end,
    }, --}}}
    { pattern = "git*", --{{{
      callback = function()
        vim.bo.bufhidden = "wipe"
        vim.wo.colorcolumn = "51,73"
        vim.bo.textwidth = 72
      end,
    }, --}}}
    { pattern = "help", --{{{
      callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[quit]])
      end,
    }, --}}}
    { pattern = "lazy", --{{{
      callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[<cmd>close<CR>]],
          { noremap = true, silent = true })
      end,
    }, --}}}
    { pattern = "qf", --{{{
      callback = function()
        vim.bo.nobuflisted = true
        vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[<cmd>close<CR>]],
          { noremap = true, silent = true })
      end,
    }, --}}}
  },
  TabClosed = { --{{{
    callback = function()
      vim.o.cmdheight = 0
      fn.switch_prior_tab()
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
      fn.refresh_git_info()
    end),
  }, --}}}
  VimLeavePre = { --{{{
    callback = function()
      vim.cmd[[cclose]]
    end,
  }, --}}}
}
