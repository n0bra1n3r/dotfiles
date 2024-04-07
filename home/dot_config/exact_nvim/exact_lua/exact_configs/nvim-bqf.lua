return {
  config = function()
    require'bqf'.setup {
      auto_enable = false,
      enable_mouse = false,
      preview = {
        border = 'single',
      },
    }
  end,
}
