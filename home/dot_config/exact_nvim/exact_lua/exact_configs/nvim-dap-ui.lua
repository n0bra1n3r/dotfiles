return {
  config = function()
    require'dapui'.setup {
      controls = {
        enabled = false,
      },
      icons = {
        collapsed = '',
        expanded = '',
      },
      layouts = {
        {
          elements = {
            {
              id = "repl",
              size = 1.0,
            },
          },
          position = "bottom",
          size = 10,
        },
        {
          elements = {
            {
              id = "scopes",
              size = 0.5,
            },
            {
              id = "stacks",
              size = 0.5,
            },
          },
          position = "right",
          size = 40,
        },
      },
    }
  end,
}
