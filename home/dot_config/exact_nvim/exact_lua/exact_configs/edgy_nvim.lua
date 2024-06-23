return {
  config = function()
    require'edgy'.setup {
      animate = {
        enabled = false,
      },
      bottom = {
        size = 10,
        {
          ft = 'qf',
          wo = {
            foldcolumn = '1',
            foldexpr = 'v:lua.fn.qf_fold_expr()',
            foldmethod = 'expr',
            wrap = false,
          },
        },
        { ft = 'dap-repl' },
        { ft = 'filter' },
      },
      right = {
        size = 10,
        { ft = 'undotree' },
        {
          ft = 'diff',
          size = {
            height = 10,
          },
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
        number = false,
        winbar = false,
        winhighlight = '',
      },
    }
  end,
}
