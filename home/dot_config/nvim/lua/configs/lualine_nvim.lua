local M = {}

function left_separator()
  return ""
end

function right_separator()
  return ""
end

function project_state(values)
  if fn.get_is_job_in_progress() then
    local secs, micros = vim.loop.gettimeofday()
    local time = secs * 1000000 + micros
    return values.job[time % #values.job + 1]
  else
    return values[fn.project_status()] or values.default
  end
end

function M.config()
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
      },
      {
        left_separator,
        padding = { left = 0, right = 0 },
      },
      {
        fn.get_workspace_dir,
        cond = fn.has_git_remote,
      }
    },
    lualine_b = {
      {
        fn.get_git_branch,
        cond = fn.is_git_dir,
        icon = '',
      },
      {
        left_separator,
        cond = fn.is_git_dir,
        padding = { left = 0, right = 1 },
      },
      {
        fn.git_local_change_count,
        cond = fn.is_git_dir,
        icon = '',
        padding = { left = 0, right = 1 },
      },
      {
        fn.git_remote_change_count,
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
      { "location" },
    },
    lualine_z = {
      {
        function()
          return vim.api.nvim_tabpage_get_number(0)
        end,
      },
      {
        right_separator,
        padding = { left = 0, right = 0 },
      },
      {
        function()
          return #vim.api.nvim_list_tabpages()
        end,
      },
    },
  }
  local winbar = {
    lualine_a = {
      { "fileformat" },
      {
        left_separator,
        padding = { left = 0, right = 0 },
      },
      {
        "filename",
        path = 1,
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
      { "b:gitsigns_status" },
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

  require"lualine".setup {
    extensions = {},
    options = {
      component_separators = "",
      disabled_filetypes = {
        winbar = { "qf" },
      },
      globalstatus = true,
      refresh = {
        statusline = 500,
      },
      section_separators = "",
      theme = "nightfox",
    },
    sections = sections,
    tabline = {},
    winbar = winbar,
    inactive_winbar = inactive_winbar,
  }
end

return M
