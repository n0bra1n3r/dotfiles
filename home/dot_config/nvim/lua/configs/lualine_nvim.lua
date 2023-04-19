local function left_component_separator()
  return ''
end

local function right_component_separator()
  return ''
end

local function left_section_separator()
  return ''
end

local function right_section_separator()
  return ''
end

local function project_state(values)
  if fn.get_is_job_in_progress() then
    return values.job
  else
    return values[fn.project_status()] or values.default
  end
end

local function section_color(section)
  return function()
    if fn.get_is_job_in_progress() then
      return "lualine_"..section.."_command"
    end
    return "lualine_"..section..require'lualine.highlight'.get_mode_suffix()
  end
end

local function section_separator_color(left, right, mode)
  return function()
    local left_highlight = mode
      and "lualine_"..left.."_normal"
      or section_color(left)()
    local right_highlight = mode
      and "lualine_"..right.."_normal"
      or section_color(right)()
    local highlight = require'lualine.highlight'.get_transitional_highlights(
      left_highlight,
      right_highlight)
    if highlight ~= nil then
      return highlight:sub(3, -2)
    end
  end
end

local function tab_name(name, context)
  local types = {}
  for _, buf in ipairs(vim.fn.tabpagebuflist(context.tabnr)) do
    if vim.startswith(vim.bo[buf].filetype, "git") then
      return ' '..name
    end
    types[vim.bo[buf].buftype] = true
  end
  local cur_path = fn.get_workspace_dir()
  local tab_path = fn.get_workspace_dir(context.tabnr)
  local label = ""
  if cur_path ~= tab_path then
    local tab_root = fn.get_git_worktree_root(context.tabnr)
    if tab_path == tab_root then
      label = vim.fn.pathshorten(vim.fn.fnamemodify(tab_path, ":~:."))
    else
      if fn.is_subpath(tab_path, tab_root) then
        label = tab_path:sub(#tab_root + 2, -1)
      end
    end
  end
  if vim.tbl_count(types) == 1 then
    if types.terminal ~= nil then
      return ' '..label
    end
  end
  if fn.is_workspace_frozen(context.tabnr) then
    return ' '..label
  end
  return ' '..label
end

function plug.config()
  local sections = {
    lualine_a = {
      {
        function()
          return project_state {
            job = '',
            default = require'lualine.utils.mode'.get_mode():sub(1, 1),
          }
        end,
        color = section_color'a',
      },
      {
        left_component_separator,
        color = section_color'a',
        padding = { left = 0, right = 0 },
      },
      {
        function()
          return vim.fn.fnamemodify(fn.get_git_worktree_root(), ":~:.")
        end,
        color = section_color'a',
      },
      {
        left_section_separator,
        color = section_separator_color('a', 'b'),
        padding = { left = 0, right = 0 },
      },
    },
    lualine_b = {
      {
        function()
          return fn.get_git_branch()
        end,
        color = section_color'b',
        cond = function()
          return fn.is_git_dir()
        end,
        icon = '',
      },
      {
        left_component_separator,
        color = section_color'b',
        cond = function()
          return fn.is_git_dir()
        end,
        padding = { left = 0, right = 0 },
      },
      {
        function()
          local status = " "..fn.git_local_change_count()
          if fn.has_git_remote() then
            local remote_status = " "..fn.git_remote_change_count()
            status = status.." "..remote_status
          end
          return status
        end,
        color = section_color'b',
        cond = function()
          return fn.is_git_dir()
        end,
      },
      {
        left_section_separator,
        color = section_separator_color('b', 'c'),
        padding = { left = 0, right = 0 },
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
        right_section_separator,
        color = section_separator_color('b', 'c'),
        padding = { left = 0, right = 0 },
      },
      {
        "location",
        color = section_color'b',
      },
    },
    lualine_z = {
      {
        "tabs",
        fmt = tab_name,
        mode = 1,
        tabs_color = {
          active = section_color'a',
          inactive = section_color'c',
        },
      },
    },
  }
  local winbar = {
    lualine_b = {
      {
        function()
          if vim.bo.modified then
            return ''
          end
          if vim.bo.readonly then
            return ''
          end
          local name = vim.fn.expand[[%:t]]
          local ext = vim.fn.expand[[%:e]]
          return require'nvim-web-devicons'.get_icon(name, ext, { default = true })
        end,
        color = "lualine_b_normal",
      },
      {
        "filename",
        path = 1,
        color = "lualine_b_normal",
        symbols = {
          modified = '',
          readonly = '',
        },
      },
      {
        left_section_separator,
        color = section_separator_color("b", "c", "normal"),
        padding = { left = 0, right = 0 },
      },
    },
    lualine_c = {
      {
        "b:gitsigns_status",
        color = "lualine_c_normal",
      },
    },
  }
  local inactive_winbar = {
    lualine_b = {
      {
        winbar.lualine_b[1][1],
        color = "lualine_b_inactive",
      },
      {
        "filename",
        path = 1,
        color = "lualine_b_inactive",
        symbols = {
          modified = '',
          readonly = '',
        },
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
        statusline = 500,
      },
      section_separators = '',
      theme = "catppuccin",
    },
    sections = sections,
    tabline = {},
    winbar = winbar,
    inactive_winbar = inactive_winbar,
  }
end
