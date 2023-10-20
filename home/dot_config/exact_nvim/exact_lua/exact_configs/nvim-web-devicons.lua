return {
  config = function()
    require'nvim-web-devicons'.setup {
      default = true,
      override = {
        nim = {
          icon = '󰆥',
          color = "orange",
          name = "Nim",
        },
        nimble = {
          icon = '󰆥',
          color = "orange",
          name = "Nimble",
        },
        nims = {
          icon = '󰆥',
          color = "orange",
          name = "NimScript",
        },
      },
    }
  end,
}
