function plug.config()
  require'catppuccin'.setup {
    flavour = "frappe",
    term_colors = true,
    transparent_background = true,
  }

  vim.cmd[[colorscheme catppuccin]]
end
