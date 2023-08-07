function plug.config()
  require'catppuccin'.setup {
    flavour = "frappe",
    integrations = {
      cmp = true,
      gitsigns = true,
      leap = true,
      mason = true,
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
      overseer = true,
      notify = true,
      telescope = true,
      treesitter = true,
      which_key = true,
    },
    term_colors = true,
    transparent_background = false,
  }

  vim.cmd.colorscheme("catppuccin")
end
