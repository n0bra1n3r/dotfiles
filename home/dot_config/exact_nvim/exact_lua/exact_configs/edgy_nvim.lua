return {
  config = function()
    require'edgy'.setup {
      animate = {
        enabled = false,
      },
      bottom = {
        {
          ft = 'qf',
          open = 'copen',
          title = 'Quickfix',
        },
        {
          ft = 'dap-repl',
          open = function()
            require'dap'.repl.open()
          end,
          title = 'Debugger',
        },
      },
      exit_when_last = true,
    }
  end,
}
