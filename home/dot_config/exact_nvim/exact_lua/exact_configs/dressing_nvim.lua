return {
  config = function()
    require'dressing'.setup {
      input = {
        border = 'single',
        get_config = function(opts)
          return opts.dressing
        end,
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
