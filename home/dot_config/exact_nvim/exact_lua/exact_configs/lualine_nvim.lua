-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
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

local function section_highlight(section)
  return function()
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
    return highlight and highlight:sub(3, -2)
  end
end

local function section_color(section)
  return fn.get_highlight_color_bg(section_highlight(section)())
end

local function mode_color(mode)
  return fn.get_highlight_color_bg("lualine_a_"..mode)
end

local function file_type_icon(file_type)
  return require'nvim-web-devicons'.get_icon(file_type)
end

local function file_type_color(file_type)
  local _, color = require'nvim-web-devicons'.get_icon_color(file_type)
  return color
end

local function tab_name(name, context)
  local types = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(context.tabId)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.bo[buf].filetype
    if vim.startswith(filetype, "git") or
        vim.tbl_contains({
          "diff",
          "search",
        }, filetype) then
      return file_type_icon(filetype)..' '..name
    end
    local buftype = vim.bo[buf].buftype
    local type = #buftype > 0 and buftype or filetype
    types[type] = (types[type] or 0) + 1
  end
  local cur_path = fn.get_workspace_dir()
  local tab_path = fn.get_workspace_dir(context.tabId)
  local label = ""
  if cur_path ~= tab_path then
    local tab_root = fn.get_git_worktree_root(context.tabId)
    if tab_path == tab_root then
      label = vim.fn.pathshorten(vim.fn.fnamemodify(tab_path, ":~:."))
    else
      if fn.is_subpath(tab_path, tab_root) then
        label = tab_path:sub(#tab_root + 2, -1)
      end
    end
  end
  if vim.tbl_count(types) == 1 then
    if types.help then
      return vim.trim('󰋖 '..label)
    end
    if types.terminal then
      return vim.trim(' '..label)
    end
    if fn.is_workspace_frozen(context.tabId) then
      for type, count in pairs(types) do
        if count == 1 then
          return vim.trim(file_type_icon(type)..' '..label)
        end
      end
    end
  end
  return vim.trim(' '..label)
end
--}}}

function plug.config()
  local sections = {
    lualine_a = {
      {
        function()
          return require'lualine.utils.mode'.get_mode():sub(1, 1)
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
          local icon = fn.has_git_remote() and '󱓎' or '󰘬'
          return icon.." "..fn.get_git_branch()
        end,
        color = section_highlight'b',
        cond = function()
          return fn.is_git_dir()
        end,
      },
      {
        left_section_separator,
        color = section_separator_highlight('b', 'c'),
        padding = 0,
      },
    },
    lualine_c = {
      {
        "diff",
        colored = true,
        cond = function()
          return fn.is_git_dir()
        end,
        source = function()
          return {
            added = fn.git_remote_change_count(),
            modified = fn.git_local_change_count(),
            removed = 0,
          }
        end,
        symbols = {
           added = '󰅟 ',
           modified = ' ',
           removed = '',
        },
      },
      {
        "diagnostics",
        sources = { fn.get_qf_diagnostics },
      },
    },
    lualine_x = {
      {
        "overseer",
        status = { require'overseer'.STATUS.RUNNING },
      },
    },
    lualine_y = {
      {
        right_section_separator,
        color = section_separator_highlight('b', 'c'),
        cond = function()
          return vim.bo.buftype ~= "terminal"
        end,
        padding = 0,
      },
      {
        "location",
        color = section_highlight'b',
        cond = function()
          local mode = require'lualine.utils.mode'.get_mode()
          return vim.bo.buftype ~= "terminal" and mode:sub(1, 1) ~= "V"
        end,
      },
      {
        function()
          local line_count = vim.fn.line("'>") - vim.fn.line("'<") + 1
          local char_count = vim.fn.wordcount().visual_chars
          return tostring(line_count) .. ":" .. tostring(char_count)
        end,
        color = section_highlight'b',
        cond = function()
          return require'lualine.utils.mode'.get_mode():sub(1, 1) == "V"
        end,
      },
    },
    lualine_z = {
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
    lualine_a = {
      {
        function()
          if vim.bo.modified then
            return ''
          end
          if vim.bo.readonly then
            return '󰈈'
          end
          return file_type_icon(vim.bo.filetype)
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
            fg = file_type_color(vim.bo.filetype),
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
            return section_separator_highlight('a', 'b', 'insert')()
          end
          return section_separator_highlight('a', 'b', 'normal')()
        end,
        padding = 0,
      },
    },
    lualine_b = {
      {
        "fileformat",
        cond = function()
          return #vim.bo.buftype == 0
        end,
        color = function()
          if vim.bo.modified then
            return "lualine_b_insert"
          end
          return "lualine_b_normal"
        end,
        symbols = {
          unix = '',
        },
      },
      {
        "encoding",
        cond = function()
          return #vim.bo.buftype == 0
        end,
        color = function()
          if vim.bo.modified then
            return "lualine_b_insert"
          end
          return "lualine_b_normal"
        end,
        padding = { left = 0, right = 1 },
      },
      {
        left_section_separator,
        cond = function()
          return #vim.bo.buftype == 0
        end,
        color = function()
          if vim.bo.modified then
            return section_separator_highlight('b', 'c', 'insert')()
          end
          return section_separator_highlight('b', 'c', 'normal')()
        end,
        padding = 0,
      },
    },
    lualine_c = {
      {
        "diagnostics",
        colored = true,
        padding = { left = 1, right = 0 },
        sources = { "nvim_diagnostic" },
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  }

  local inactive_winbar = vim.deepcopy(winbar)
  for _, section in pairs(inactive_winbar) do
    for i, component in pairs(section) do
      if component.show_inactive ~= false then
        if component.color ~= nil then
          component.color = "lualine_a_inactive"
          if component[1] == left_section_separator then
            component[1] = left_component_separator
          elseif component[1] == right_section_separator then
            component[1] = right_component_separator
          end
        end
        if component.colored then
          component.colored = false
        end
      else
        section[i] = {}
      end
    end
  end

  local tabline = {
    lualine_c = fn.get_debug_toolbar(),
  }
  table.insert(tabline.lualine_c, 1, "%=")
  table.insert(tabline.lualine_c, "%=")
  table.insert(tabline.lualine_c, function()
    vim.o.showtabline = fn.get_is_debugging() and 2 or 0
    return [[]]
  end)

  require'lualine'.setup {
    extensions = {},
    options = {
      always_divide_middle = false,
      component_separators = "",
      disabled_filetypes = {
        winbar = { "help", "search", "qf", "toggleterm" },
      },
      globalstatus = true,
      refresh = {
        statusline = vim.o.updatetime,
        winbar = vim.o.updatetime,
      },
      section_separators = '',
      theme = "catppuccin",
    },
    sections = sections,
    tabline = tabline,
    winbar = winbar,
    inactive_winbar = inactive_winbar,
  }

  vim.o.showtabline = 0
end
