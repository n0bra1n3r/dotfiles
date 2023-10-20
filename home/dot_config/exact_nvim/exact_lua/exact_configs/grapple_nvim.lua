return {
  config = function()
    require'grapple'.setup {
      scope = "global",
      save_path = ".nvim/favorites",
    }
  end,
}
