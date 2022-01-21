local M = {}

function M.config()


  require"lualine".setup {
    options = {
      theme = "nightfox",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch",
        "diff",
        {
          "diagnostics",
          sources = { "nvim_diagnostic", fn.get_qf_diagnostics },
        },
        fn.get_job_progress,
      },
      lualine_c = {
        function()
          return vim.fn.expand('%:~:.')
        end
      },
      lualine_x = { "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" }
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        function()
          return vim.fn.expand('%:~:.')
        end
      },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {}
    },
    extensions = { "nvim-tree", "quickfix", "toggleterm" },
  }
end

return M
