function plug.config()
  require'dressing'.setup {
    input = {
      border = 'single',
    },
    select = {
      builtin = {
        border = 'single',
      },
      nui = {
        border = {
          style = 'single',
        },
      },
    },
  }
end
