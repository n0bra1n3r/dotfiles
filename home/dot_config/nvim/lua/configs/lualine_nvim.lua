local M = {}

function left_separator()
  return ""
end

function right_separator()
  return ""
end

local project_state_index = 0
function project_state(values)
  if fn.get_is_job_in_progress() then
    local icon = values.job[project_state_index + 1]
    project_state_index = project_state_index + 1
    project_state_index = project_state_index % #values.job
    return icon
  else
    project_state_index = 0
    return values[fn.project_status()] or values.default
  end
end

function bar_color(section)
  return function()
    if fn.get_is_job_in_progress() then
      return "lualine_"..section.."_command"
    end
  end
end

function plug.config()
  local sections = {
    lualine_a = {
      {
        function()
          local mode = require'lualine.utils.mode'.get_mode():sub(1, 1)
          if fn.is_git_dir() then
            return project_state {
              job = { '', '', '' },
              default = mode,
            }
          end
          return mode
        end,
        color = bar_color'a',
      },
      {
        left_separator,
        color = bar_color'a',
        padding = { left = 0, right = 0 },
      },
      {
        fn.get_workspace_dir,
        color = bar_color'a',
        cond = fn.has_git_remote,
      }
    },
    lualine_b = {
      {
        fn.get_git_branch,
        color = bar_color'b',
        cond = fn.is_git_dir,
        icon = '',
      },
      {
        left_separator,
        color = bar_color'b',
        cond = fn.is_git_dir,
        padding = { left = 0, right = 1 },
      },
      {
        fn.git_local_change_count,
        color = bar_color'b',
        cond = fn.is_git_dir,
        icon = '',
        padding = { left = 0, right = 1 },
      },
      {
        fn.git_remote_change_count,
        color = bar_color'b',
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
    lualine_y = {
      {
        "location",
        color = bar_color'b',
      },
    },
    lualine_z = {
      {
        function()
          return vim.api.nvim_tabpage_get_number(0)
        end,
        color = bar_color'a',
      },
      {
        right_separator,
        color = bar_color'a',
        padding = { left = 0, right = 0 },
      },
      {
        function()
          return #vim.api.nvim_list_tabpages()
        end,
        color = bar_color'a',
      },
    },
  }
  local winbar = {
    lualine_a = {
      {
        "fileformat",
        color = "lualine_b_normal",
      },
      {
        left_separator,
        color = "lualine_b_normal",
        padding = { left = 0, right = 0 },
      },
      {
        "filename",
        color = "lualine_b_normal",
        path = 1,
        symbols = {
          modified = ' ●',
          readonly = ' ',
        },
      },
      {
        left_separator,
        color = "lualine_b_normal",
        cond = function()
          return vim.b.gitsigns_status ~= nil and #vim.b.gitsigns_status > 0
        end,
        padding = { left = 0, right = 0 },
      },
      {
        "b:gitsigns_status",
        color = "lualine_b_normal",
      },
    },
  }
  local inactive_winbar = {
    lualine_a = {
      {
        "fileformat",
        color = "lualine_a_inactive",
      },
      {
        left_separator,
        padding = { left = 0, right = 0 },
      },
      {
        "filename",
        path = 1,
        color = "lualine_a_inactive",
        symbols = {
          modified = ' ●',
          readonly = ' ',
        },
      },
      {
        left_separator,
        cond = function()
          return vim.b.gitsigns_status ~= nil and #vim.b.gitsigns_status > 0
        end,
        padding = { left = 0, right = 0 },
      },
      {
        "b:gitsigns_status",
        color = "lualine_a_inactive",
      },
    },
  }

  require'lualine'.setup {
    extensions = {},
    options = {
      component_separators = "",
      disabled_filetypes = {
        winbar = { "qf", "toggleterm" },
      },
      globalstatus = true,
      refresh = {
        statusline = 250,
      },
      section_separators = "",
    },
    sections = sections,
    tabline = {},
    winbar = winbar,
    inactive_winbar = inactive_winbar,
  }
end
