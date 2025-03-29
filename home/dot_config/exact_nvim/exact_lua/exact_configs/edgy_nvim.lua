return {
  config = function()
    require 'edgy'.setup {
      animate = {
        enabled = false,
      },
      options = {
        left = {
          size = 0.25,
        },
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
        { ft = 'filter' },
      },
      left = {
        {
          ft = 'codecompanion',
          wo = {
            number = false,
          },
        },
      },
      right = {
        {
          ft = 'diff',
          size = {
            height = 10,
          },
        },
        { ft = 'undotree' },
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
        winhighlight = '',
      },
    }
  end,
}
