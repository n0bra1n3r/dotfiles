-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Constants
local mode_names = {
  ['\19'] = 'S',
  ['\22'] = '󰫙',
  ['\22s'] = '󰫙',
  ['!'] = '!',
  c = '󰘳',
  ce = 'E',
  cv = 'E',
  i = '󰧺',
  ic = '󰧺',
  ix = '󰧺',
  n = '',
  niI = '',
  niR = '',
  niV = '',
  no = '',
  nov = '',
  noV = '',
  ['no\22'] = '',
  nt = '',
  r = '·',
  rm = 'M',
  ['r?'] = '?',
  R = 'R',
  Rc = 'R',
  Rv = 'R',
  Rvc = 'R',
  Rvx = 'R',
  Rx = 'R',
  s = 'S',
  S = 'S',
  t = '',
  v = '󰮐',
  vs = '󰮐',
  V = '󰮐',
  Vs = '󰮐',
}
--}}}

--{{{ Colors
local function colors()
  local hl = require'heirline.utils'.get_highlight
  return {
    background = hl'TabLine'.bg,
    bookmark = hl'TabLine'.fg,
    bookmark_key = hl'Comment'.fg,
    border = hl'TabLine'.bg,
    buffer = hl'Title'.fg,
    buffer_inactive = hl'Comment'.fg,
    buffer_modified = hl'String'.fg,
    close_btn = hl'Comment'.fg,
    default = hl'Normal'.bg,
    diagnostic_inactive = hl'Comment'.fg,
    diagnostic_Error = hl'DiagnosticError'.fg,
    diagnostic_Hint = hl'DiagnosticHint'.fg,
    diagnostic_Info = hl'DiagnosticInfo'.fg,
    diagnostic_Warn = hl'DiagnosticWarn'.fg,
    keymap = hl'TabLine'.fg,
    git_branch = hl'Comment'.fg,
    git_branch_synced = hl'String'.fg,
    git_local = hl'DiagnosticHint'.fg,
    git_remote = hl'DiagnosticWarn'.fg,
    git_stash = hl'DiagnosticInfo'.fg,
    location = hl'String'.fg,
    separator = hl'Normal'.bg,
    tab = hl'Directory'.fg,
    tab_inactive = hl'Comment'.fg,
    task_running = hl'String'.fg,
    workspace = hl'Title'.fg,
  }
end

local function mode_colors()
  local c = require'catppuccin.palettes'.get_palette()
  return {
    ['\19'] = c.maroon,
    ['\22'] = c.flamingo,
    ['\22s'] = c.flamingo,
    ['!'] = c.green,
    c = c.peach,
    ce = c.peach,
    cv = c.peach,
    i = c.green,
    ic = c.green,
    ix = c.green,
    n = c.blue,
    ni = c.blue,
    no = c.blue,
    nt = c.blue,
    r = c.teal,
    rm = c.teal,
    ['r?'] = c.mauve,
    R = c.maroon,
    Rc = c.maroon,
    Rv = c.maroon,
    Rx = c.maroon,
    s = c.maroon,
    S = c.maroon,
    t = c.green,
    v = c.flamingo,
    vs = c.flamingo,
    V = c.flamingo,
    Vs = c.flamingo,
  }
end
--}}}

--{{{ Helpers
local function space(count)
  local width = count or 1
  if width <= 0 then
    return {
      provider = function()
        local winid = vim.fn.win_getid()
        return (' '):rep(vim.fn.getwininfo(winid)[1].textoff + width)
      end,
    }
  elseif width < math.huge then
    return { provider = (' '):rep(width) }
  else
    return { provider = '%= ' }
  end
end

local function border(char)
  return {
    hl = { fg = 'border' },
    provider = char,
  }
end

local function sep(char)
  return {
    hl = { fg = 'separator' },
    provider = char,
  }
end

local function get_visible_buf_type_counts(tab)
  local types = {}
  if vim.api.nvim_tabpage_is_valid(tab) then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_get_config(win).relative == [[]] then
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.bo[buf].filetype
        local buftype = vim.bo[buf].buftype
        local type = #buftype > 0 and buftype or filetype
        types[type] = (types[type] or 0) + 1
      end
    end
  end
  return types
end

local function refresh_bookmark_list()
  local old_showtabline = vim.o.showtabline
  vim.o.showtabline = #require'grapple'.tags() > 0 and 2 or 0
  if vim.o.showtabline == old_showtabline and vim.o.showtabline ~= 0 then
    vim.schedule(vim.cmd.redrawtabline)
  end
end
--}}}

--{{{ Statusline
local function mode_label()
  return {
    init = function(self)
      self.task_count = 0
      local is_ok, overseer_task_list = pcall(require, 'overseer.task_list')
      if is_ok then
        self.task_count = #overseer_task_list.list_tasks {
          status = require'overseer'.STATUS.RUNNING,
        }
      end
    end,
    {
      hl = { fg = 'task_running', bold = true },
      provider = function(self)
        return self.task_count > 0 and '' or ' '
      end,
    },
    {
      hl = function(self)
        local mode = self.mode:sub(1, 2)
        return { fg = self.mode_colors[mode], bold = true }
      end,
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = function(self)
        return self.mode_names[self.mode]..' '
      end,
      static = {
        mode_colors = mode_colors(),
        mode_names = mode_names,
      },
      update = { 'ModeChanged' },
    },
  }
end

local function git_repo_status()
  return {
    hl = function(self)
      local hl = fn.has_git_remote(self.cwd)
        and 'git_branch_synced'
        or 'git_branch'
      return { fg = hl, italic = true }
    end,
    provider = function(self)
      local icon = fn.has_git_remote(self.cwd) and '󱓎' or '󰘬'
      return icon..' '..fn.get_git_branch(self.cwd)
    end,
  },
  {
    condition = function(self)
      return fn.git_stash_count(self.cwd) > 0
    end,
    space(),
    {
      hl = { fg = 'git_stash' },
      provider = function(self)
        return '󰇙'..fn.git_stash_count(self.cwd)
      end,
    },
  },
  {
    condition = function(self)
      return fn.git_remote_change_count(self.cwd) > 0
    end,
    space(),
    {
      hl = { fg = 'git_remote' },
      provider = function(self)
        return ''..fn.git_remote_change_count(self.cwd)
      end,
    },
  },
  {
    condition = function(self)
      return fn.git_local_change_count(self.cwd) > 0
    end,
    space(),
    {
      hl = { fg = 'git_local' },
      provider = function(self)
        return ''..fn.git_local_change_count(self.cwd)
      end,
    },
  }
end

local function workspace_label()
  return {
    border'',
    {
      hl = { bg = 'background' },
      init = function(self)
        self.cwd = fn.get_tab_cwd()
      end,
      space(),
      {
        hl = { fg = 'workspace', bold = true },
        provider = function(self)
          local root = fn.get_git_worktree_root(self.cwd)
          return vim.fn.fnamemodify(root, ':~:.')
        end,
      },
      {
        condition = function(self)
          return fn.is_git_dir(self.cwd)
        end,
        space(),
        sep'╱',
        space(),
        git_repo_status(),
      },
      space(),
    },
    border'',
  }
end

local function debug_btn()
  return {
    condition = function(self)
      return self.cond_cb()
    end,
    init = function(self)
      self.child_index.value = self.child_index.value + 1
    end,
    {
      space(),
      condition = function(self)
        return self.child_index.value > 1
      end,
      sep'│',
      space(),
    },
    {
      on_click = {
        callback = function(self)
          self.click_cb()
        end,
        name = function(self)
          return 'debug_click_callback'..self.action
        end,
      },
      {
        hl = function(self)
          return self.highlight
        end,
        provider = function(self)
          return self.icon
        end,
      },
      space(),
      {
        hl = { fg = 'keymap' },
        provider = function(self)
          return self.keymap
        end,
      },
    },
  }
end

local function debug_bar()
  return {
    condition = function()
      return fn.get_is_debugging()
    end,
    border'',
    {
      hl = { bg = 'background' },
      init = function(self)
        self.child_index = { value = 0 }

        local toolbar = fn.get_debug_toolbar()
        for i, item in ipairs(toolbar) do
          local child = self[i]
          if not child or child.icon ~= item.icon then
            self[i] = self:new({
              hl = { bg = 'background' },
              debug_btn(),
            }, i)
            child = self[i]
            child.action = item.action
            child.highlight = item.highlight
            child.icon = item.icon
            child.keymap = item.keymap
            child.click_cb = item.click_cb
            child.cond_cb = item.cond_cb
          end
        end
        if #self > #toolbar then
          for i = #toolbar + 1, #self do
            self[i] = nil
          end
        end
      end,
    },
    border'',
  }
end

local function location_label()
  return {
    condition = function()
      local win = vim.api.nvim_get_current_win()
      return not fn.is_terminal_buf(vim.api.nvim_win_get_buf(win))
    end,
    border'',
    {
      hl = { bg = 'background' },
      init = function(self)
        local win = vim.api.nvim_get_current_win()
        self.cursor = vim.api.nvim_win_get_cursor(win)
      end,
      update = { 'CursorMoved','CursorMovedI' },
      space(),
      {
        hl = { fg = 'location', italic = true },
        provider = function(self)
          local line_num = tostring(self.cursor[1])
          return (' '):rep(3 - #line_num)..'L'..line_num
        end,
      },
      space(),
      sep'╱',
      space(),
      {
        hl = { fg = 'location', italic = true },
        provider = function(self)
          local col_num = tostring(self.cursor[2])
          return 'C'..col_num..(' '):rep(3 - #col_num)
        end,
      },
      space(),
    },
    border'',
  }
end

local function tab_btn()
  return {
    init = function(self)
      local cur_win = vim.api.nvim_tabpage_get_win(self.tab)
      local cur_buf = vim.api.nvim_win_get_buf(cur_win)
      self.name = vim.api.nvim_buf_get_name(cur_buf)
    end,
    {
      space(),
      condition = function(self)
        return vim.api.nvim_tabpage_get_number(self.tab) > 1
      end,
      sep'│',
      space(),
    },
    {
      hl = function(self)
        local is_cur = self.tab == vim.api.nvim_get_current_tabpage()
        local hl = is_cur and 'tab' or 'tab_inactive'
        return { fg = hl, bold = is_cur, italic = is_cur }
      end,
      on_click = {
        callback = function(self)
          vim.api.nvim_set_current_tabpage(self.tab)
        end,
        name = function(self)
          return 'tab_click_callback'..self.tab
        end,
      },
      provider = function(self)
        local icon = ''
        local label = [[]]

        local cur_path = fn.get_workspace_dir()
        local tab_path = fn.get_workspace_dir(self.tab)
        if cur_path ~= tab_path then
          local tab_root = fn.get_git_worktree_root(self.tab)
          if tab_path == tab_root then
            label = vim.fn.pathshorten(vim.fn.fnamemodify(tab_path, ":~:."))
          elseif fn.is_subpath(tab_path, tab_root) then
            label = tab_path:sub(#tab_root + 2, -1)
          else
            label = self.name
          end
        end

        local types = get_visible_buf_type_counts(self.tab)
        if vim.tbl_count(types) == 1 then
          if types.help then
            icon = '󰋖'
          elseif types.terminal and not fn.get_shell_active() then
            icon = ''
          elseif types.terminal and fn.get_shell_active() then
            icon = '%#String#󱆃%*'
          elseif fn.is_workspace_frozen(self.tab) then
            icon = require'nvim-web-devicons'.get_icon(vim.tbl_keys(types)[1])
          end
        end

        return vim.trim(icon..' '..label)
      end,
    },
  }
end

local function tabs_bar()
  return {
    border'',
    {
      hl = { bg = 'background' },
      init = function(self)
        local tabs = vim.api.nvim_list_tabpages()
        for i, tab in ipairs(tabs) do
          local child = self[i]
          if not child or child.tab ~= tab then
            self[i] = self:new({
              hl = { bg = 'background' },
              tab_btn(),
            }, i)
            child = self[i]
            child.tab = tab
          end
        end
        if #self > #tabs then
          for i = #tabs + 1, #self do
            self[i] = nil
          end
        end
      end,
    },
    border'',
  }
end
--}}}

--{{{ Tabline
local function bookmark_label()
  return {
    { provider = '󰃀', hl = { fg = 'bookmark_key' } },
    space(),
    {
      hl = { fg = 'bookmark_key', bold = true },
      provider = function(self)
        return self.key
      end,
    },
    space(),
    {
      hl = { fg = 'bookmark' },
      on_click = {
        callback = function(self, minwid)
          if fn.is_terminal_buf(minwid) then
            fn.set_terminal_dir(vim.fn.fnamemodify(self.path, ':h'))
          else
            require'grapple'.select{ key = self.key }
          end
        end,
        minwid = function()
          return vim.api.nvim_get_current_buf()
        end,
        name = function(self)
          return 'bookmark_select_callback'..self.key
        end,
      },
      provider = function(self)
        return vim.fn.fnamemodify(self.path, ':~:.')
      end,
    },
  }
end

local function bookmark_del_btn()
  return {
    {
      hl = { fg = 'close_btn' },
      on_click = {
        callback = function(self)
          require'grapple'.untag{ key = self.key }
          refresh_bookmark_list()
        end,
        name = function(self)
          return 'bookmark_untag_callback'..self.key
        end,
      },
      provider = '󰅖',
    },
  }
end

local function bookmarks_bar()
  return {
    init = function(self)
      local tags = require'grapple'.tags()
      for i, tag in ipairs(tags) do
        local child = self[i]
        if not child or
          child.path ~= tag.file_path or
          child.key ~= tag.key
        then
          self[i] = self:new({
            hl = { bg = 'default' },
            space(),
            border'',
            {
              hl = { bg = 'background' },
              space(),
              bookmark_label(),
              space(),
              sep'│',
              space(),
              bookmark_del_btn(),
              space(),
            },
          }, i)
          child = self[i]
          child.key = tag.key
          child.path = tag.file_path
        end
      end
      if #self > #tags then
        for i = #tags + 1, #self do
          self[i] = nil
        end
      end
    end,
  }
end
--}}}

--{{{ Winbar
local function header_icon()
  return {
    hl = function(self)
      local fg = self.icon_color
      if not require'heirline.conditions'.is_active() then
        fg = 'buffer_inactive'
      elseif vim.bo.modified then
        fg = 'buffer_modified'
      end
      return { fg = fg }
    end,
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ':e')
      self.icon, self.icon_color = require'nvim-web-devicons'.get_icon_color(
        filename,
        extension,
        { default = true })
    end,
    provider = function(self)
      if vim.bo.readonly then return '󰈈' end
      return vim.bo.modified and '' or self.icon
    end,
  }
end

local function header_label()
  return {
    {
      hl = function()
        local fg = 'buffer_inactive'
        local is_active = require'heirline.conditions'.is_active()
        if is_active then
          fg = vim.bo.modified and 'buffer_modified' or 'buffer'
        end
        return { fg = fg, bold = is_active, italic = is_active }
      end,
      {
        provider = function(self)
          local filename = vim.fn.fnamemodify(self.filename, ':~:.')
          return #filename == 0 and '[No Name]' or filename
        end,
      },
    },
  }
end

local function header_close_btn()
  return {
    sep'',
    {
      hl = { fg = 'close_btn' },
      on_click = {
        callback = function(_, minwid)
          vim.api.nvim_win_close(minwid, false)
        end,
        minwid = function()
          return vim.api.nvim_get_current_win()
        end,
        name = 'window_close_callback',
      },
      provider = '󰅖',
    },
  }
end

local function header()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
      self.win = vim.api.nvim_get_current_win()
    end,
    update = { 'BufEnter', 'BufModifiedSet' },
    border'',
    {
      hl = { bg = 'background' },
      header_icon(),
      space(),
      header_label(),
      space(),
      header_close_btn(),
    },
    border'',
  }
end

local function diagnostic_label(severity)
  return {
    init = function(self)
      self.child_index.value = self.child_index.value + 1
      self.count = self.counts[severity]
      self.icon = self.icons[severity]
      self.name = self.severities[severity]
    end,
    condition = function(self)
      return self.counts[severity] > 0
    end,
    {
      space(),
      condition = function(self)
        return self.child_index.value > 1
      end,
      sep'│',
      space(),
    },
    {
      on_click = {
        callback = function(_, minwid)
          vim.api.nvim_set_current_win(minwid)
          vim.diagnostic.goto_next{ severity = severity }
        end,
        minwid = function()
          return vim.api.nvim_get_current_win()
        end,
        name = function(self)
          return 'diagnostic_click_callback'..self.name
        end,
      },
      hl = function(self)
        if not require'heirline.conditions'.is_active() then
          return { fg = 'diagnostic_inactive' }
        end
        return { fg = 'diagnostic_'..self.name }
      end,
      provider = function(self)
        return self.icon..self.count
      end,
    },
  }
end

local function diagnostics_bar()
  local s = vim.diagnostic.severity
  local severities = {
    [s.ERROR] = 'Error',
    [s.WARN] = 'Warn',
    [s.HINT] = 'Hint',
    [s.INFO] = 'Info',
  }
  local icons = {}
  for severity, name in pairs(severities) do
    icons[severity] = vim.fn.sign_getdefined('DiagnosticSign'..name)[1].text
  end
  return {
    condition = require'heirline.conditions'.has_diagnostics,
    init = function(self)
      self.win = vim.api.nvim_get_current_win()
      self.counts = {}
      for severity, _ in pairs(self.severities) do
        self.counts[severity] = #vim.diagnostic.get(0, { severity = severity })
      end
    end,
    static = {
      icons = icons,
      severities = severities,
    },
    border'',
    {
      hl = { bg = 'background' },
      init = function(self)
        self.child_index = { value = 0 }
      end,
      update = { 'DiagnosticChanged', 'BufEnter' },
      diagnostic_label(s.ERROR),
      diagnostic_label(s.WARN),
      diagnostic_label(s.INFO),
      diagnostic_label(s.HINT),
    },
    border'',
  }
end

local function bookmark_btn()
  return {
    init = function(self)
      self.buf = vim.api.nvim_get_current_buf()
    end,
    border'',
    {
      hl = { bg = 'background' },
      on_click = {
        callback = function(_, minwid)
          local tags = require'grapple'.tags()
          vim.fn.sort(tags, function(a, b) return a.key - b.key end)
          local key
          for i, tag in ipairs(tags) do
            if i ~= tag.key then
              key = i
              break
            end
          end
          require'grapple'.toggle{ buffer = minwid, key = key }
          refresh_bookmark_list()
        end,
        minwid = function()
          return vim.api.nvim_get_current_buf()
        end,
        name = function(self)
          return 'bookmark_tag_callback'..self.buf
        end,
      },
      {
        hl = function()
          return require'heirline.conditions'.is_active()
            and 'WinBar'
            or 'Comment'
        end,
        provider = function(self)
          return require'grapple'.exists{ buffer = self.buf }
            and '󰃀' or '󰃃'
        end,
      },
    },
    border'',
  }
end
--}}}

function plug.config()
  require'heirline'.load_colors(colors())

  require'heirline'.setup {
    opts = {
      disable_winbar_cb = function(args)
        return fn.is_floating() or
          require'heirline.conditions'.buffer_matches({
            buftype = {
              'help',
              'search',
              'qf',
            },
            filetype = {
              'search',
              'toggleterm',
            },
          }, args.buf)
      end,
    },
    statusline = {
      hl = { bg = 'default' },
      space(),
      mode_label(),
      space(),
      workspace_label(),
      space(math.huge),
      debug_bar(),
      space(math.huge),
      location_label(),
      space(),
      tabs_bar(),
    },
    tabline = {
      hl = { bg = 'default' },
      space(math.huge),
      bookmarks_bar(),
    },
    winbar = {
      hl = { bg = 'default' },
      space(-3),
      header(),
      space(),
      diagnostics_bar(),
      space(math.huge),
      bookmark_btn(),
    },
  }

  vim.api.nvim_create_autocmd({
    'ColorScheme',
    'FocusLost',
    'FocusGained',
    'WinEnter',
  }, {
    group = vim.api.nvim_create_augroup('conf_heirline', { clear = true }),
    callback = function()
      require'heirline.utils'.on_colorscheme(colors)
    end,
  })

  refresh_bookmark_list()
end
