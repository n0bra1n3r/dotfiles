local M = {}

function get_project_git_status()
  if fn.is_git_dir() then
    local branch = fn.get_git_branch()
    return {
      up = fn.git_remote_change_count(),
      down = fn.git_local_change_count(),
    }
  end

  return { up = [[]], down = [[]] }
end

function project_state(values)
  if fn.get_is_job_in_progress() then
    return values.job
  else
    return values[fn.project_status()] or values.default
  end
end

function M.config()
  local sections = {
    lualine_a = {
      {
        "mode",
        fmt = function(str)
          return str:sub(1, 1)
        end,
      },
    },
    lualine_b = {
      { "fileformat" },
      {
        "filename",
        file_status = true,
        padding = { left = 0, right = 1 },
        path = 1,
        symbols = {
          modified = ' ●',
          readonly = ' ﯎',
          unnamed = "[New File]",
        },
      },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {
      { "location" },
    },
  }

  require"lualine".setup {
    extensions = {},
    options = {
      component_separators = "",
      disabled_filetypes = {
        statusline = { "qf" },
      },
      section_separators = "",
      theme = "nightfox",
    },
    sections = sections,
    inactive_sections = sections,
    tabline = {
      lualine_a = {
        {
          function()
            return string.format("%s %s", project_state{ job = '', default = '' }, fn.get_project_dir())
          end,
          color = function()
            return project_state {
              job = "lualine_a_insert",
              default = "lualine_a_normal",
            }
          end,
          cond = fn.is_git_dir,
        },
      },
      lualine_b = {
        {
          "branch",
          color = function()
            return project_state {
              job = "lualine_b_insert",
              default = "lualine_b_normal",
            }
          end,
          cond = fn.is_git_dir,
        },
        {
          function()
            return get_project_git_status().down
          end,
          color = function()
            return project_state {
              job = "lualine_b_insert",
              default = "lualine_b_normal",
            }
          end,
          cond = fn.is_git_dir,
          icon = '',
          padding = { left = 0, right = 1 },
        },
        {
          function()
            return get_project_git_status().up
          end,
          color = function()
            return project_state {
              job = "lualine_b_insert",
              default = "lualine_b_normal",
            }
          end,
          cond = fn.has_git_remote,
          icon = '',
          padding = { left = 0, right = 1 },
        },
      },
      lualine_c = {
        {
          "diagnostics",
          sources = { fn.get_qf_diagnostics },
        },
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {
        {
          "buffers",
          buffers_color = {
            active = function()
              return project_state {
                job = "lualine_a_insert",
                default = "lualine_a_normal",
              }
            end,
            inactive = function()
              return project_state {
                job = "lualine_b_insert",
                default = "lualine_b_normal",
              }
            end,
          },
          hide_filename_extension = true,
          mode = 4,
          show_modified_status = true,
        },
        {
          "tabs",
          tabs_color = {
            active = function()
              return project_state {
                job = "lualine_a_insert",
                default = "lualine_a_normal",
              }
            end,
            inactive = function()
              return project_state {
                job = "lualine_b_insert",
                default = "lualine_b_normal",
              }
            end,
          },
        },
      },
    },
  }
end

return M
