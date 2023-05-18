function plug.config()
  require'telescope'.setup {
    defaults = {
      file_ignore_patterns = {
        ".git",
      },
      mappings = {
        i = {
          ["<Esc>"] = require'telescope.actions'.close,
        },
      },
      preview = {
        check_mime_type = true,
      },
      prompt_prefix = ' ',
    },
    pickers = {
      loclist = {
        fname_width = 9999,
        mappings = {
          i = {
            ["<Tab>"] = function(bufnr)
              require'telescope.actions.set'.edit(bufnr, "drop")
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
        path_display = function(opts, path)
          return vim.fn.fnamemodify(path, ":~:.")
        end,
        theme = "dropdown",
      },
      find_files = {
        mappings = {
          i = {
            ["<C-\\>"] = function(bufnr)
              require'telescope.actions.set'.edit(bufnr, "vsplit")
            end,
            ["<C-->"] = function(bufnr)
              require'telescope.actions.set'.edit(bufnr, "split")
            end,
            ["<S-Tab>"] = function(bufnr)
              require'telescope.actions'.move_selection_previous(bufnr)
            end,
            ["<Tab>"] = function(bufnr)
              require'telescope.actions'.move_selection_next(bufnr)
            end,
          },
        },
      },
    },
  }
end
