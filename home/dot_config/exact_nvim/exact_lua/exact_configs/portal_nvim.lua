return {
  config = function()
    require'portal'.setup {
      log_level = "error",
      labels = { "j", "k", "l", ";" },
    }
  end,
}
