return {
  config = function()
    require'git-conflict'.setup {
      disable_diagnostics = true,
    }
  end,
}
