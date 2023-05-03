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

local function project_state(values)
  if fn.get_is_job_in_progress() then
    return fn.job_indicator()
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
    local filetype = vim.bo[buf].filetype
    if vim.startswith(filetype, "git") or
        vim.tbl_contains({
          "diff",
        }, filetype) then
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
    if types.help ~= nil then
      return '󰋖 '..label
    end
    if types.terminal ~= nil then
      return ' '..label
    end
  end
  if fn.is_workspace_frozen(context.tabnr) then
    return ' '..label
  end
  return ' '..label
end

local function diagnostics_at_line()
  return vim.diagnostic.get(0, { lnum = vim.fn.line"." - 1 })
end
--}}}

function plug.config()
  local sections = {
    lualine_a = {
      {
        function()
          return project_state {
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
           added = ' ',
           modified = ' ',
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
        function()
          local severities = { "Error", "Warn", "Info", "Hint" }
          local diagnostics = diagnostics_at_line()
          local max_severity = 4
          local max_severity_idx = 1
          for i, diagnostic in ipairs(diagnostics) do
            if diagnostic.severity < max_severity then
              max_severity = diagnostic.severity
              max_severity_idx = i
            end
          end
          local diagnostic = diagnostics[max_severity_idx]
          local severity_text = severities[max_severity]
          return ("%s (%d, %d) %s: %s"):format(
            my_config.signs["DiagnosticSign"..severity_text].text,
            vim.fn.line"." - 1,
            diagnostic.col + 1,
            diagnostic.code,
            diagnostic.message)
        end,
        color = function()
          local severities = { "Error", "Warn", "Info", "Hint" }
          local diagnostics = diagnostics_at_line()
          local max_severity = 4
          for _, diagnostic in ipairs(diagnostics) do
            max_severity = math.min(max_severity, diagnostic.severity)
          end
          local severity_text = severities[max_severity]
          return "Diagnostic"..severity_text
        end,
        cond = function()
          return #diagnostics_at_line() > 0
        end,
      },
    },
    lualine_y = {
      {
        right_section_separator,
        color = section_separator_highlight('b', 'c'),
        padding = 0,
      },
      {
        "location",
        color = section_highlight'b',
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
        sources = { "nvim_lsp", "nvim_diagnostic" },
      },
    },
    lualine_x = {
      {
        "lsp_progress",
        display_components = {
          "spinner",
          "lsp_client_name",
        },
        spinner_symbols = {
          '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷',
        },
      },
    },
    lualine_y = {},
    lualine_z = {},
  }
  local inactive_winbar = vim.deepcopy(winbar)
  for _, section in pairs(inactive_winbar) do
    for _, component in pairs(section) do
      if component.color ~= nil then
        component.color = "lualine_b_inactive"
        if component[1] == left_section_separator then
          component[1] = left_component_separator
        elseif component[1] == right_section_separator then
          component[1] = right_component_separator
        end
      end
      if component.colored ~= nil then
        component.colored = false
      end
    end
  end
  require'lualine'.setup {
    extensions = {},
    options = {
      always_divide_middle = false,
      component_separators = "",
      disabled_filetypes = {
        winbar = { "help", "qf", "toggleterm" },
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
    tabline = {},
    winbar = winbar,
    inactive_winbar = inactive_winbar,
  }
end
