function plug.config()
  require'telescope'.setup {
    defaults = {
      file_ignore_patterns = {
        "%.DS_Store",
        "%.git[\\/].*",
        ".*%.bin",
        ".*%.db.*",
        ".*%.dll",
        ".*%.exe",
        ".*%.exp",
        ".*%.ilk",
        ".*%.lib",
        ".*%.opendb",
        ".*%.pdb",
        ".*%.sln",
        ".*%.suo",
        ".*%.vcxproj.*",
        "^build[\\/].*",
        "^nimcache[\\/].*",
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
    },
  }
end
