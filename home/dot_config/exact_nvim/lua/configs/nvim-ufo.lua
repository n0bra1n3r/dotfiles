function plug.config()
  require'ufo'.setup {
    open_fold_hl_timeout = 0,
    provider_selector = function()
      return { "treesitter", "indent" }
    end,
  }
end
