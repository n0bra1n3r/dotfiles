return {
  config = function()
    require'avante'.setup {
      windows = {
        width = 30,
        sidebar_header = {
          align = 'left',
          rounded = false,
        },
        input = {
          height = 10,
        },
        edit = {
          border = 'rounded',
        },
        ask = {
          border = 'rounded',
        },
      },
    }
  end,
}
