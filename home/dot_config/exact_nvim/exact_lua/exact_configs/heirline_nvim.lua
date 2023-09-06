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
    return { provider = '%=' }
  end
end

local function border(char, color)
  return {
    provider = char,
    hl = { fg = color },
  }
end

local function tab_label()
  return {
    {
      provider = '󰃀',
      hl = 'Comment',
    },
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

local function tab_add_btn()
  return {
    provider = '󰃅',
    hl = 'Comment',
    on_click = {
      callback = function()
        local tags = require'grapple'.tags()
        vim.fn.sort(tags, function(a, b) return a.key - b.key end)
        local key
        for i, tag in ipairs(tags) do
          if i ~= tag.key then
            key = i
            break
          end
        end
        require'grapple'.tag{ key = key }
        vim.schedule(vim.cmd.redrawtabline)
      end,
      name = 'bookmark_tag_callback',
    },
  }
end

local function update_tabline_visibility()
  vim.o.showtabline = #require'grapple'.tags() > 0 and 2 or 0
end

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
        if not get_is_active() then
          return {
            fg = get_fg'Comment',
            bold = true,
            italic = true,
          }
        elseif vim.bo.modified then
          return {
            fg = get_fg'String',
            bold = true,
            italic = true,
          }
        else
          return {
            fg = get_fg'Title',
            bold = true,
            italic = true,
          }
        end
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
        name = function(self)
          return 'window_close_callback'..self.win
        end,
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

local function diagnostics()
  return {
    condition = require'heirline.conditions'.has_diagnostics,
    border('', get_bg'TabLine'),
    {
      init = function(self)
        self.win = vim.api.nvim_get_current_win()
        self.error_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warn_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hint_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
      end,
      static = {
        error_icon = vim.fn.sign_getdefined('DiagnosticSignError')[1].text,
        warn_icon = vim.fn.sign_getdefined('DiagnosticSignWarn')[1].text,
        info_icon = vim.fn.sign_getdefined('DiagnosticSignInfo')[1].text,
        hint_icon = vim.fn.sign_getdefined('DiagnosticSignHint')[1].text,
      },
      update = { 'DiagnosticChanged', 'BufEnter' },
      hl = 'TabLine',
      space(),
      {
        condition = function(self)
          return self.error_count > 0
        end,
        {
          provider = function(self)
            return self.error_icon..self.error_count
          end,
          hl = function()
            if not get_is_active() then
              return { fg = get_fg'Comment' }
            else
              return { fg = get_fg'DiagnosticError' }
            end
          end,
        },
        on_click = {
          callback = function(_, minwid)
            vim.api.nvim_set_current_win(minwid)
            vim.diagnostic.goto_next{ severity = vim.diagnostic.severity.ERROR }
          end,
          minwid = function()
            return vim.api.nvim_get_current_win()
          end,
          name = function(self)
            return 'diagnostic_error_click_callback'..self.win
          end,
        },
        space(),
      },
      {
        condition = function(self)
          return self.error_count > 0 and
            (self.warn_count > 0 or
              self.info_count > 0 or
              self.hint_count > 0)
        end,
        border('┃', get_bg'Normal'),
        space(),
      },
      {
        condition = function(self)
          return self.warn_count > 0
        end,
        {
          provider = function(self)
            return self.warn_icon..self.warn_count
          end,
          hl = function()
            if not get_is_active() then
              return { fg = get_fg'Comment' }
            else
              return { fg = get_fg'DiagnosticWarn' }
            end
          end,
        },
        on_click = {
          callback = function(_, minwid)
            vim.api.nvim_set_current_win(minwid)
            vim.diagnostic.goto_next{ severity = vim.diagnostic.severity.WARN }
          end,
          minwid = function()
            return vim.api.nvim_get_current_win()
          end,
          name = function(self)
            return 'diagnostic_warn_click_callback'..self.win
          end,
        },
        space(),
      },
      {
        condition = function(self)
          return self.warn_count > 0 and
            (self.info_count > 0 or
              self.hint_count > 0)
        end,
        border('┃', get_bg'Normal'),
        space(),
      },
      {
        condition = function(self)
          return self.info_count > 0
        end,
        {
          provider = function(self)
            return self.info_icon..self.info_count
          end,
          hl = function()
            if not get_is_active() then
              return { fg = get_fg'Comment' }
            else
              return { fg = get_fg'DiagnosticInfo' }
            end
          end,
        },
        on_click = {
          callback = function(_, minwid)
            vim.api.nvim_set_current_win(minwid)
            vim.diagnostic.goto_next{ severity = vim.diagnostic.severity.INFO }
          end,
          minwid = function()
            return vim.api.nvim_get_current_win()
          end,
          name = function(self)
            return 'diagnostic_info_click_callback'..self.win
          end,
        },
        space(),
      },
      {
        condition = function(self)
          return self.info_count > 0 and self.hint_count > 0
        end,
        border('┃', get_bg'Normal'),
        space(),
      },
      {
        condition = function(self)
          return self.hint_count > 0
        end,
        {
          provider = function(self)
            return self.hint_icon..self.hint_count
          end,
          hl = function()
            if not get_is_active() then
              return { fg = get_fg'Comment' }
            else
              return { fg = get_fg'DiagnosticHint' }
            end
          end,
        },
        on_click = {
          callback = function(_, minwid)
            vim.api.nvim_set_current_win(minwid)
            vim.diagnostic.goto_next{ severity = vim.diagnostic.severity.HINT }
          end,
          minwid = function()
            return vim.api.nvim_get_current_win()
          end,
          name = function(self)
            return 'diagnostic_hint_click_callback'..self.win
          end,
        },
        space(),
      },
    },
    border('', get_bg'TabLine'),
  }
end

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
          update_tabline_visibility()
        end,
      },
      tab_add_btn(),
      space(),
    },
    winbar = {
      hl = 'Normal',
      space(-3),
      header(),
      space(),
      diagnostics(),
    },
  }

  update_tabline_visibility()
end
