local M = {}

function M.config()
  require"bufferline".setup {
    options = {
      custom_areas = {
        right = function()
          if fn.is_git_dir() then
            return {{ text = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.") }}
          end
        end
      },
      custom_filter = fn.filter_buffers,
      numbers = function(opts)
        return string.format('%s%s', opts.id, opts.raise(opts.ordinal))
      end,
      show_buffer_close_icons = false,
      show_close_icon = false,
      sort_by = fn.sort_buffers
    }
  }
end

return M
