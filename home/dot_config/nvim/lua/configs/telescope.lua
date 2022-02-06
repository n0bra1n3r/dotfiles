local M = {}

function M.config()
  require"telescope".setup {
    defaults = {
      cache_picker = {
        num_pickers = 5,
      },
      file_ignore_patterns = {
        "%.dll",
        "%.exe",
        "%.glb",
        "%.gltf",
        "%.pdb",
        ".git",
      },
      mappings = {
        i = {
          ["<Esc>"] = require"telescope.actions".close,
          ["<M-\\>"] = function(bufnr)
            require"telescope.actions.set".edit(bufnr, "vsplit")
          end,
          ["<M-->"] = function(bufnr)
            require"telescope.actions.set".edit(bufnr, "split")
          end,
          ["<M-=>"] = function(bufnr)
            require"telescope.actions.set".edit(bufnr, "tabnew")
          end,
          ["<M-l>"] = function(bufnr)
            require"telescope.actions.set".edit(bufnr, "edit")
          end,
          ["<M-;>"] = function(bufnr)
            require"telescope.actions.set".edit(bufnr, "vsplit")
          end,
          ["<M-e>"] = function(bufnr)
            require"telescope.actions.set".scroll_previewer(bufnr, 1)
          end,
          ["<M-y>"] = function(bufnr)
            require"telescope.actions.set".scroll_previewer(bufnr, -1)
          end,
          ["<M-p>"] = require"telescope.actions.layout".toggle_preview,
          ["<S-Tab>"] = function(bufnr)
            require"telescope.actions".move_selection_previous(bufnr)
          end,
          ["<Tab>"] = function(bufnr)
            require"telescope.actions".move_selection_next(bufnr)
          end,
        },
      },
    },
    pickers = {
      buffers = {
        theme = "dropdown",
      },
      find_files = {
        theme = "dropdown",
      },
      live_grep = {
        theme = "ivy",
      },
    },
    extensions = {
      fzf = {
        case_mode = "smart_case",
        fuzzy = true,
        override_file_sorter = true,
        override_generic_sorter = true,
      }
    },
  }

  require"telescope".load_extension("fzf")
end

return M
