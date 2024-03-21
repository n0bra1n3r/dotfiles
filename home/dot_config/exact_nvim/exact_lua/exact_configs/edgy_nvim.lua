return {
  config = function()
    require'edgy'.setup {
      animate = {
        enabled = false,
      },
      bottom = {
        {
          ft = 'qf',
          title = 'Quickfix',
        },
        {
          ft = 'dap-repl',
          title = 'Debugger',
        },
      },
      exit_when_last = true,
      keys = {
        ['<C-q>'] = false,
        ['<Esc>'] = function(win)
          fn.close_window(win.win)
        end,
        q = false,
      },
      wo = {
        winbar = false,
      },
    }
  end,
}
