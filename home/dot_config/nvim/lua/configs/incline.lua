local M = {}

function M.config()
  require"incline".setup{
    render = function(props)
      local label = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":~:.")
      local format = vim.api.nvim_buf_get_option(props.buf, "fileformat")
      local isModified = vim.api.nvim_buf_get_option(props.buf, "modified")

      label = ({
        unix = "",
        dos = "",
        mac = "",
      })[format].." "..label

      if isModified then
        label = label.." ●"
      end

      return { label }
    end,
    window = {
      winhighlight = {
        active = { Normal = "lualine_a_normal" },
        inactive = { Normal = "lualine_a_inactive" },
      },
    },
  }
end

return M
