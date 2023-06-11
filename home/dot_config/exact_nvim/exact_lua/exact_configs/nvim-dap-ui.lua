function plug.config()
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
            id = "scopes",
            size = 0.4,
          },
          {
            id = "stacks",
            size = 0.4,
          },
          {
            id = "breakpoints",
            size = 0.2,
          },
        },
        position = "left",
        size = 40,
      },
      {
        elements = {
          {
            id = "console",
            size = 1.0,
          },
        },
        position = "bottom",
        size = 10,
      },
    },
  }
end
