local M = {}

function project_info()
  local area = {}
  if fn.is_git_dir() then
    if fn.project_status() == "debug" then
      local hl = vim.api.nvim_get_hl_by_name("WarningMsg", true)
      local fg = string.format("#%06x", hl.foreground)
      table.insert(area, {
        guifg = fg,
        guibg = "NONE",
        text = string.format(" ? %s ", vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")),
      })
    else
      local hl = vim.api.nvim_get_hl_by_name("Directory", true)
      local fg = string.format("#%06x", hl.foreground)
      table.insert(area, {
        guifg = fg,
        guibg = "NONE",
        text = string.format(" ? %s ", vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")),
      })
    end
  end
  return area
end

function M.config()
  local theme = "nightfox"

  require"lualine".setup {
    extensions = { "nvim-tree", "quickfix" },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {
        {
          "filename",
          file_status = true,
          path = 1,
          symbols = {
            modified = ' ●',
            readonly = ' ﯎',
            unnamed = "[New File]",
          }
        },
      },
      lualine_c = {
        {
          "filetype",
          colored = false,
          icon_only = true,
        },
      },
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
          "filename",
          file_status = true,
          path = 1,
          symbols = {
            modified = ' ●',
            readonly = ' ﯎',
            unnamed = "[New File]",
          }
        },
        {
          "b:gitsigns_status",
          padding = { left = 0, right = 1 },
        },
      },
      lualine_c = {
        {
          "filetype",
          colored = true,
          icon_only = true,
          padding = { left = 1, right = 0 },
        },
      },
      lualine_x = { "fileformat" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    tabline = {
      lualine_a = { "tabs" },
      lualine_b = {
        {
          "buffers",
          icons_enabled = false,
          mode = 2,
          show_filename_only = false,
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
        {
          "diagnostics",
          padding = { left = 0, right = 1 },
          sources = { "nvim_diagnostic", fn.get_qf_diagnostics },
        },
      },
      lualine_z = {
        {
          "branch",
          color = "lualine_a_normal",
        },
      },
    },
  }
end

return M
