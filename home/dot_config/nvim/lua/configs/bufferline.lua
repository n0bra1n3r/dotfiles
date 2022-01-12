local M = {}

function M.config()
  require"bufferline".setup {
    highlights = {
      buffer_selected = {
        gui = "bold",
      },
    },
    options = {
      custom_areas = {
        right = function()
          if fn.is_git_dir() then
            return {{ text = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.") }}
          end
        end
      },
      custom_filter = fn.filter_buffers,
      diagnostics = false,
      numbers = function(opts)
        return opts.id
      end,
      show_buffer_close_icons = false,
      show_buffer_icons = false,
      show_close_icon = false,
      sort_by = fn.sort_buffers,
    }
  }
end

return M
