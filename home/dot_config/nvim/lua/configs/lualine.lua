local M = {}

function buffer_git_status()
  if vim.b.gitsigns_status_dict ~= nil then
    return {
      added = vim.b.gitsigns_status_dict.added,
      modified = vim.b.gitsigns_status_dict.changed,
      removed = vim.b.gitsigns_status_dict.removed,
    }
  end
end

function M.config()
  local theme = "nightfox"

  require"lualine".setup {
    extensions = { "nvim-tree", "quickfix" },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {
        {
          "filetype",
          colored = false,
          icon_only = true,
          padding = { left = 1, right = 0 },
        },
        {
          "filename",
          file_status = true,
          path = 1,
          symbols = {
            modified = ' ',
            readonly = ' ﯎',
            unnamed = "[New File]",
          },
        },
      },
      lualine_c = {},
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {}
    },
    options = {
      theme = theme,
      component_separators = "",
      section_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        {
          "filetype",
          colored = false,
          icon_only = true,
          padding = { left = 1, right = 0 },
        },
        {
          "filename",
          file_status = true,
          path = 1,
          symbols = {
            modified = ' ',
            readonly = ' ﯎', 
            unnamed = "[New File]",
          },
        },
        {
          'diff',
          padding = { left = 0, right = 1 },
          symbols = { added = ' ', modified = ' ', removed = ' ' },
          source = buffer_git_status,
        },
      },
      lualine_c = {},
      lualine_x = { "fileformat" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    tabline = {
      lualine_a = { "tabs" },
      lualine_b = {
        {
          "buffers",
          mode = 2,
          show_modified_status = false,
        },
      },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {
        {
          function()
            local icon
            if fn.get_is_job_in_progress() then
              icon = ''
            else
              if fn.project_status() == "debug" then
                icon = ''
              else
                icon = ''
              end
            end
            local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")
            return string.format("%s %s", icon, cwd)
          end,
          color = "lualine_b_normal",
          cond = fn.is_git_dir,
        },
      },
      lualine_z = {
        {
          function()
            return vim.b.gitsigns_status_dict.head
          end,
          color = "lualine_a_normal",
          cond = fn.is_git_dir,
          icon = ''
        },
      },
    },
  }
end

return M
