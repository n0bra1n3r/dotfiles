function plug.config()
  require'telescope'.setup {
    defaults = {
      borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      history = false,
      mappings = {
        i = {
          ["<Esc>"] = require'telescope.actions'.close,
        },
      },
      preview = {
        check_mime_type = true,
      },
      prompt_prefix = ' ',
    },
    pickers = {
      loclist = {
        fname_width = 9999,
        mappings = {
          i = {
            ["<Tab>"] = function(bufnr)
              require'telescope.actions.set'.edit(bufnr, "edit")
            end,
            ["<C-S-Tab>"] = function(bufnr)
              require'telescope.actions'.move_selection_previous(bufnr)
            end,
            ["<S-Tab>"] = function(bufnr)
              require'telescope.actions'.move_selection_previous(bufnr)
            end,
            ["<C-Tab>"] = function(bufnr)
              require'telescope.actions'.move_selection_next(bufnr)
            end,
          },
        },
        path_display = function(_, path)
          return vim.fn.fnamemodify(path, ":~:.")
        end,
        theme = "dropdown",
      },
      quickfix = {
        theme = "dropdown",
      },
    },
  }

  require'telescope'.load_extension("dap")
end
