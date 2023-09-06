function plug.config()
  require'catppuccin'.setup {
    flavour = "frappe",
    background = {
      dark = "frappe",
      light = "latte",
    },
    custom_highlights = function()
      return my_config.highlights
    end,
    integrations = {
      cmp = true,
      dap = {
        enabled = true,
        enable_ui = true,
      },
      gitsigns = true,
      leap = true,
      markdown = true,
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
        inlay_hints = {
          background = true,
        },
      },
      overseer = true,
      notify = true,
      semantic_tokens = true,
      telescope = true,
      treesitter = true,
      --ufo = true,
      which_key = true,
      window_picker = true,
    },
  }

  vim.cmd.colorscheme[[catppuccin]]
end
