return {
  config = function()
    require'mini.splitjoin'.setup {
      separator = "[,;|]",
    }
  end,
}
