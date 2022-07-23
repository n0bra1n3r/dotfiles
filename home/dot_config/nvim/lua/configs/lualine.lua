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
  local project_dir = fn.get_project_dir()
  local project_git_status = get_project_git_status()

  require"lualine".setup {
    extensions = { "nvim-tree", "quickfix" },
    options = {
      component_separators = "",
      globalstatus = true,
      section_separators = "",
      theme = "nightfox",
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(str)
            return str:sub(1, 1)
          end,
        },
      },
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
            modified = ' ●',
            readonly = ' ﯎',
            unnamed = "[New File]",
          },
        },
        {
          'diff',
          colored = false,
          symbols = { added = ' ', modified = ' ', removed = ' ' },
          source = buffer_git_status,
        },
      },
      lualine_c = {},
      lualine_x = { "fileformat" },
      lualine_y = { "encoding" },
      lualine_z = { "location" },
    },
    tabline = {
      lualine_a = {
        {
          function()
            return string.format("%s %s", project_state{ job = '', default = '' }, project_dir)
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
            return project_git_status.down
          end,
          color = function()
            return project_state {
              job = "lualine_b_insert",
              default = "lualine_b_normal",
            }
          end,
          cond = fn.is_git_dir,
          icon = '',
        },
        {
          function()
            return project_git_status.up
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
      lualine_c = {},
      lualine_x = {
        {
          "diagnostics",
          sources = { fn.get_qf_diagnostics },
        },
      },
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
