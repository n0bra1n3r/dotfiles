function plug.config()
  require'catppuccin'.setup {
    flavour = "frappe",
    integrations = {
      cmp = true,
      fidget = true,
      gitsigns = true,
      leap = true,
      mini = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
			},
      telescope = true,
      treesitter = true,
    },
    term_colors = true,
    transparent_background = true,
    which_key = true,
  }

  vim.cmd[[colorscheme catppuccin]]
end
