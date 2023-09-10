function plug.config()
  local dismissed_notifs = {}

  require'notify'.setup {
    icons = {
      DEBUG = '󰉄',
      ERROR = '',
      INFO = '',
      TRACE = '󰎈',
      WARN = ''
    },
    on_open = function(win, record)
      vim.api.nvim_create_autocmd('WinEnter', {
        buffer = vim.api.nvim_win_get_buf(win),
        callback = function()
          dismissed_notifs[record.id] = true
          vim.api.nvim_win_close(win, true)
        end,
      })
    end,
    stages = {
      function(state)
        local next_height = state.message.height + 2
        local next_row = require'notify.stages.util'.available_slot(
          state.open_windows,
          next_height,
          require'notify.stages.util'.DIRECTION.BOTTOM_UP
        )
        if not next_row then
          return nil
        end
        local row = next_row == vim.o.lines - next_height
          and next_row - 1
          or next_row
        return {
          anchor = 'NE',
          border = 'single',
          col = vim.o.columns,
          height = state.message.height,
          relative = 'editor',
          row = row,
          style = 'minimal',
          width = state.message.width,
        }
      end,
      function()
        return {
          col = { vim.o.columns },
          time = true,
        }
      end,
    },
    top_down = false,
  }

  vim.notify = function(msg, level, opts)
    local notify_level = {
      [vim.log.levels.DEBUG] = 'DEBUG',
      [vim.log.levels.ERROR] = 'ERROR',
      [vim.log.levels.INFO] = 'INFO',
      [vim.log.levels.TRACE] = 'TRACE',
      [vim.log.levels.WARN] = 'WARN',
      [vim.log.levels.OFF] = 'OFF',
    }

    if not opts then
      opts = {}
    end

    opts.animate = false

    if (not opts.title or #opts.title == 0) and not opts.replace then
      opts.title = "neovim"
    end

    local max_len = 50

    if opts.title and #opts.title > max_len then
      opts.title = opts.title:sub(1, 20)..'...'..opts.title:sub(-20, -1)
    end

    local lines

    if msg then
      lines = {}

      for _, line in ipairs(vim.split(msg, '\n')) do
        for j = 1, #line, max_len do
          table.insert(lines, line:sub(j, j + max_len - 1))
        end
      end
    end

    if not opts.replace then
      local job = require'plenary.job':new {
        args = { vim.fn.expand'~/.dotfiles/scripts/bell' },
        command = "sh",
        detached = true,
      }
      job:start()
    end

    if not dismissed_notifs[opts.replace and opts.replace.id] then
      return require'notify'(lines, notify_level[level], opts)
    end
  end
end
