function plug.config()
  require'dressing'.setup {
    input = {
      border = "single",
      get_config = function(opts)
        return opts.dressing
      end,
    },
    select = {
      builtin = {
        border = "single",
      },
      nui = {
        border = {
          style = "single",
        },
      },
    },
  }
end
