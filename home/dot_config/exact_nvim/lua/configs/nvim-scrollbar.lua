function plug.config()
  require'scrollbar'.setup {
    show_in_active_only = true,
    hide_if_all_visible = true,
  }
  require'scrollbar.handlers.gitsigns'.setup()
  require'scrollbar.handlers.search'.setup()
end
