function plug.config()
  require'telescope'.setup {
    defaults = {
      file_ignore_patterns = {
        "^%.git[\\/]",
      },
      history = false,
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
        hidden = true,
        mappings = {
          i = {
            ["<M-\\>"] = function(bufnr)
              require'telescope.actions.set'.edit(bufnr, "vsplit")
            end,
            ["<M-->"] = function(bufnr)
              require'telescope.actions.set'.edit(bufnr, "split")
            end,
            ["<S-Tab>"] = function(bufnr)
              require'telescope.actions'.move_selection_next(bufnr)
            end,
            ["<Tab>"] = function(bufnr)
              require'telescope.actions'.move_selection_previous(bufnr)
            end,
            ["<M-j>"] = function(bufnr)
              require'telescope.actions'.move_selection_next(bufnr)
            end,
            ["<M-k>"] = function(bufnr)
              require'telescope.actions'.move_selection_previous(bufnr)
            end,
          },
        },
      },
    },
  }
end
