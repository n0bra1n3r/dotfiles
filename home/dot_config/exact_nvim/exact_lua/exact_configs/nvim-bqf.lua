return {
  config = function()
    require'bqf'.setup {
      enable_mouse = false,
      preview = {
        border = 'single',
      },
    }
  end,
}
