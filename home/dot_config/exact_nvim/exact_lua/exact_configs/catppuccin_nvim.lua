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
  }

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("conf_catppuccin", { clear = true }),
    callback = fn.vim_defer(function()
      if vim.startswith(vim.g.colors_name, "catppuccin") then
        require'catppuccin'.load(require'catppuccin'.flavour)
      end
    end)
  })

  vim.cmd.colorscheme("catppuccin")
end
