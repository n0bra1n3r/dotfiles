local M = {}

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
        function()
          local mode = require'lualine.utils.mode'.get_mode():sub(1, 1)
          if fn.is_git_dir() then
            return string.format("%s  %s", project_state {
              job = 'ﲊ',
              default = mode,
            }, fn.get_workspace_dir())
          end
          return mode
        end,
      },
    },
    lualine_b = {
      {
        fn.get_git_branch,
        cond = fn.is_git_dir,
        icon = '',
      },
      {
        function() return "" end,
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
          local tab = vim.api.nvim_tabpage_get_number(0)
          local tabCount = #vim.api.nvim_list_tabpages()
          return string.format("%d  %d", tab, tabCount)
        end,
      },
    },
  }
  local winbar = {
    lualine_a = {
      { "fileformat" },
      {
        function() return "" end,
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
    },
  }
  local inactive_winbar = {
    lualine_a = {
      {
        "fileformat",
        color = "lualine_a_inactive",
      },
      {
        function()
          return ""
        end,
        padding = { left = 0, right = 0 },
      },
      {
        "filename",
        path = 1,
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
