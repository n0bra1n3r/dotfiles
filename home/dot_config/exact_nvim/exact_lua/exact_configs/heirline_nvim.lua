-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function refresh_tabline()
  vim.o.showtabline = #require'grapple'.tags() > 0 and 2 or 0
end

local function get_bg(name)
  return require'heirline.utils'.get_highlight(name).bg
end

local function get_fg(name)
  return require'heirline.utils'.get_highlight(name).fg
end

local function get_is_active()
  return require'heirline.conditions'.is_active()
end

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

local function border(char, color)
  return {
    provider = char,
    hl = { fg = color },
  }
end
--}}}

--{{{ Tabline
local function tab_label()
  return {
    { provider = '󰃀', hl = 'Comment' },
    space(),
    {
      provider = function(self)
        return self.key
      end,
      hl = { bold = true, italic = true },
    },
    space(),
    {
      provider = function(self)
        return vim.fn.fnamemodify(self.path, ':~:.')
      end,
      hl = { italic = true },
      on_click = {
        callback = function(self)
          require'grapple'.select{ key = self.key }
          vim.schedule(vim.cmd.redrawtabline)
        end,
        name = function(self)
          return 'bookmark_select_callback'..self.key
        end,
      },
    },
  }
end

local function tab_close_btn()
  return {
    {
      provider = '',
      hl = 'Comment',
      on_click = {
        callback = function(self)
          require'grapple'.untag{ key = self.key }
          vim.schedule( vim.cmd.redrawtabline)
        end,
        name = function(self)
          return 'bookmark_untag_callback'..self.key
        end,
      },
    },
  }
end

local function tab()
  return {
    border('', get_bg'TabLine'),
    {
      hl = 'TabLine',
      space(),
      tab_label(),
      space(2),
      tab_close_btn(),
      space(),
    },
    border('', get_bg'TabLine'),
  }
end
--}}}

--{{{ Winbar
local function header_icon()
  return {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ':e')
      self.icon, self.icon_color = require'nvim-web-devicons'.get_icon_color(
        filename,
        extension,
        { default = true })
    end,
    provider = function(self)
      if vim.bo.modified then
        return ''
      elseif vim.bo.readonly then
        return '󰈈'
      else
        return self.icon
      end
    end,
    hl = function(self)
      if not get_is_active() then
        return 'Comment'
      elseif vim.bo.modified then
        return 'String'
      else
        return { fg = self.icon_color }
      end
    end
  }
end

local function header_label()
  return {
    {
      hl = function()
        local hl
        if not get_is_active() then
          hl = 'Comment'
        elseif vim.bo.modified then
          hl = 'String'
        else
          hl = 'Title'
        end
        return {
          fg = get_fg(hl),
          bold = true,
          italic = true,
        }
      end,
      {
        provider = function(self)
          local filename = vim.fn.fnamemodify(self.filename, ':~:.')
          if #filename == 0 then
            return '[No Name]'
          else
            return filename
          end
        end,
      },
    },
  }
end

local function header_close_btn()
  return {
    {
      provider = '',
      hl = 'Comment',
      on_click = {
        callback = function(_, minwid)
          vim.api.nvim_win_close(minwid, false)
        end,
        minwid = function()
          return vim.api.nvim_get_current_win()
        end,
        name = 'window_close_callback',
      },
    },
  }
end

local function header()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
      self.win = vim.api.nvim_get_current_win()
    end,
    border('', get_bg'TabLine'),
    {
      hl = 'TabLine',
      header_icon(),
      space(2),
      header_label(),
      space(),
      {
        condition = function()
          return not vim.bo.modified
        end,
        border('┃', get_bg'Normal'),
        space(),
        header_close_btn(),
      },
    },
    border('', get_bg'TabLine'),
  }
end

local function diagnostic(severity)
  return {
    condition = function(self)
      return self.counts[severity] > 0
    end,
    init = function(self)
      self.count = self.counts[severity]
      self.icon = self.icons[severity]
      self.name = self.severities[severity]
    end,
    {
      provider = function(self)
        return self.icon..self.count
      end,
      hl = function(self)
        if not get_is_active() then
          return { fg = get_fg'Comment' }
        else
          return { fg = get_fg('Diagnostic'..self.name) }
        end
      end,
    },
    on_click = {
      callback = function(_, minwid)
        vim.api.nvim_set_current_win(minwid)
        vim.diagnostic.goto_next{ severity = severity }
      end,
      minwid = function()
        return vim.api.nvim_get_current_win()
      end,
      name = function(self)
        return 'diagnostic_'..self.name..'_click_callback'
      end,
    },
    space(),
  }
end

local function diagnostics()
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
    border('', get_bg'TabLine'),
    {
      update = { 'DiagnosticChanged', 'BufEnter' },
      hl = 'TabLine',
      space(),
      diagnostic(s.ERROR),
      {
        condition = function(self)
          return self.counts[s.ERROR] > 0 and
            (self.counts[s.WARN] > 0 or
              self.counts[s.INFO] > 0 or
              self.counts[s.HINT] > 0)
        end,
        border('┃', get_bg'Normal'),
        space(),
      },
      diagnostic(s.WARN),
      {
        condition = function(self)
          return self.counts[s.WARN] > 0 and
            (self.counts[s.INFO] > 0 or
              self.counts[s.HINT] > 0)
        end,
        border('┃', get_bg'Normal'),
        space(),
      },
      diagnostic(s.INFO),
      {
        condition = function(self)
          return self.counts[s.INFO] > 0 and
            self.counts[s.HINT] > 0
        end,
        border('┃', get_bg'Normal'),
        space(),
      },
      diagnostic(s.HINT),
    },
    border('', get_bg'TabLine'),
  }
end

local function bookmark()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    border('', get_bg'TabLine'),
    {
      hl = 'TabLine',
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
          print(minwid)
          require'grapple'.toggle{ buffer = minwid, key = key }
          vim.schedule(vim.cmd.redrawtabline)
        end,
        minwid = function()
          return vim.api.nvim_get_current_buf()
        end,
        name = 'bookmark_tag_callback',
      },
      space(),
      {
        provider = function(self)
          if require'grapple'.exists{ file_path = self.filename } then
            return '󰃀'
          else
            return '󰃃'
          end
        end,
        hl = function()
          if not get_is_active() then
            return 'Comment'
          else
            return 'WinBar'
          end
        end,
      },
      space(),
    },
    border('', get_bg'TabLine'),
  }
end
--}}}

function plug.config()
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
    tabline = {
      hl = 'Normal',
      space(math.huge),
      {
        init = function(self)
          local tags = require'grapple'.tags()
          for i, tag in ipairs(tags) do
            local child = self[i]
            if not child or child.path ~= tag.file_path or child.key ~= tag.key
            then
              self[i] = self:new({
                hl = 'Normal',
                space(),
                tab(),
                space(),
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
          refresh_tabline()
        end,
      },
    },
    winbar = {
      hl = 'Normal',
      space(-3),
      header(),
      space(),
      diagnostics(),
      space(math.huge),
      bookmark(),
      space(),
    },
  }

  refresh_tabline()
end
