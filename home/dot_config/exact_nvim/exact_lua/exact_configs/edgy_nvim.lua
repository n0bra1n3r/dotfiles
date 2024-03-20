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
        {
          ft = 'Trouble',
          open = 'Trouble',
          title = 'Trouble',
        },
      },
      exit_when_last = true,
      keys = {
        ['<C-q>'] = false,
        ['<Esc>'] = function(win)
          if win.view.ft == 'qf' then
            vim.cmd.cclose()
          elseif win.view.ft == 'Trouble' then
            vim.cmd.TroubleClose()
          else
            win.view.edgebar:close()
          end
        end,
        q = false,
      },
    }
  end,
}
