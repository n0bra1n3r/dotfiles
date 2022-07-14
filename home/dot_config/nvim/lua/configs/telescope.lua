local M = {}

function previewer(path, bufnr, opts)
  path = vim.fn.expand(path)
  require"plenary.job":new({
    command = "file",
    args = { "--mime-type", "-b", path },
    on_exit = function(output)
      local mimeType = vim.split(output:result()[1], "/")[1]
      if mimeType == "text" then
        vim.loop.fs_stat(path, function(_, stat)
          if stat and stat.size < 500000 then
            require"telescope.previewers".buffer_previewer_maker(path, bufnr, opts)
          else
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                "----",
                "type: "..mimeType,
                "size: "..tostring(stat.size),
                "----",
              })
            end)
          end
        end)
      else
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "----",
            "type: "..mimeType,
            "size: <unknown>",
            "----",
          })
        end)
      end
    end,
  }):sync()
end

function M.config()
  require"telescope".setup {
    defaults = {
      buffer_previewer_maker = previewer,
      file_ignore_patterns = {
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
      git_files = {
        theme = "dropdown",
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
end

return M
