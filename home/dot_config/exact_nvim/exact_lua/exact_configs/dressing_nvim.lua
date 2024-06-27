return {
  config = function()
    require'dressing'.setup {
      input = {
        border = 'single',
        get_config = function(opts)
          return opts.dressing
        end,
        mappings = {
          i = {
            ['<C-c>'] = false,
            ['<Esc>'] = 'Close',
          },
        },
      },
      select = {
        builtin = {
          border = 'single',
        },
        get_config = function(opts)
          return opts.dressing
        end,
        nui = {
          border = {
            style = 'single',
          },
        },
      },
    }
  end,
}
