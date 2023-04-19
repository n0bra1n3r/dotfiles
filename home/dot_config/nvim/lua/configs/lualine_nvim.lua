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

local function section_highlight(section)
  return function()
    if fn.get_is_job_in_progress() then
      return "lualine_"..section.."_command"
    end
    return "lualine_"..section..require'lualine.highlight'.get_mode_suffix()
  end
end

local function section_separator_highlight(left, right, mode)
  return function()
    local left_highlight = mode
      and "lualine_"..left.."_"..mode
      or section_highlight(left)()
    local right_highlight = mode
      and "lualine_"..right.."_"..mode
      or section_highlight(right)()
    local highlight = require'lualine.highlight'.get_transitional_highlights(
      left_highlight,
      right_highlight)
    if highlight ~= nil then
      return highlight:sub(3, -2)
    end
  end
end

local function highlight_color(name)
  local hl = vim.api.nvim_get_hl(0, { name = name })
  return ('%06X'):format(hl.bg)
end

local function section_color(section)
  return highlight_color(section_highlight(section)())
end

local function mode_color(mode)
  return highlight_color("lualine_a_"..mode)
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
        color = function()
          return {
            bg = 'none',
            fg = section_color'a',
          }
        end,
        padding = 2,
      },
      {
        function()
          return vim.fn.fnamemodify(fn.get_git_worktree_root(), ":~:.")
        end,
        color = section_highlight'a',
      },
      {
        left_section_separator,
        color = section_separator_highlight('a', 'b'),
        padding = 0,
      },
    },
    lualine_b = {
      {
        function()
          return fn.get_git_branch()
        end,
        color = section_highlight'b',
        cond = function()
          return fn.is_git_dir()
        end,
        icon = '',
      },
      {
        left_section_separator,
        color = section_separator_highlight('b', 'c'),
        padding = 0,
      },
    },
    lualine_c = {
      {
        "diagnostics",
        color = "lualine_a_inactive",
        sources = { fn.get_qf_diagnostics },
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {
      {
        function()
          local local_hl = "%#lualine_x_diff_modified_command#"
          local remote_hl = "%#lualine_x_diff_added_command#"
          local status = local_hl.." "..fn.git_local_change_count()
          if fn.has_git_remote() then
            local remote_status = remote_hl.." "..fn.git_remote_change_count()
            status = status.." "..remote_status
          end
          return status
        end,
        color = "lualine_a_inactive",
        cond = function()
          return fn.is_git_dir()
        end,
      },
      {
        "location",
        color = function()
          return {
            bg = 'none',
            fg = section_color'a',
          }
        end,
      },
      {
        "tabs",
        fmt = tab_name,
        mode = 1,
        tabs_color = {
          active = section_highlight'a',
          inactive = section_highlight'b',
        },
      },
    },
  }
  local winbar = {
    lualine_b = {
      {
        function()
          if vim.bo.modified then
            return ''
          end
          if vim.bo.readonly then
            return ''
          end
          local name = vim.fn.expand[[%:t]]
          local ext = vim.fn.expand[[%:e]]
          return require'nvim-web-devicons'.get_icon(name, ext, { default = true })
        end,
        color = function()
          if vim.bo.modified then
            return {
              bg = 'none',
              fg = mode_color'insert',
            }
          end
          return {
            bg = 'none',
            fg = mode_color'normal',
          }
        end,
        padding = 2,
      },
      {
        "filename",
        color = function()
          if vim.bo.modified then
            return "lualine_a_insert"
          end
          return "lualine_a_normal"
        end,
        file_status = false,
        path = 1,
      },
      {
        left_section_separator,
        color = function()
          if vim.bo.modified then
            return section_separator_highlight('a', 'c', 'insert')()
          end
          return section_separator_highlight('a', 'c', 'normal')()
        end,
        padding = 0,
      },
    },
    lualine_c = {
      {
        "diagnostics",
        color = "lualine_a_inactive",
        colored = true,
        sources = { "nvim_lsp" },
      },
    },
    lualine_x = {
      {
        "diff",
        color = "lualine_a_inactive",
        colored = true,
        cond = function()
          local status = vim.b.gitsigns_status_dict
          return status ~= nil and vim.tbl_count(status) > 0
        end,
        source = function()
          local status = vim.b.gitsigns_status_dict
          status.modified = status.changed
          return status
        end,
        symbols = {
           added = ' ',
           modified = ' ',
           removed = ' ',
        },
      },
    },
  }
  local inactive_winbar = vim.deepcopy(winbar)
  for name, section in pairs(inactive_winbar) do
    for _, component in pairs(section) do
      if component.color ~= nil then
        component.color = name.."_inactive"
        if component.colored ~= nil then
          component.colored = false
        end
        if component[1] == left_section_separator then
          component[1] = left_component_separator
        elseif component[1] == right_section_separator then
          component[1] = right_component_separator
        end
      end
    end
  end
  require'lualine'.setup {
    extensions = {},
    options = {
      always_divide_middle = false,
      component_separators = "",
      disabled_filetypes = {
        winbar = { "qf", "toggleterm" },
      },
      globalstatus = true,
      refresh = {
        statusline = 500,
        winbar = 500,
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
