function plug.config()
  require'notify'.setup {
    fps = 1,
    icons = {
      DEBUG = '󰉄',
      ERROR = '',
      INFO = '',
      TRACE = '󰎈',
      WARN = ''
    },
    stages = "static",
    top_down = false,
  }

  vim.notify = function(msg, level, opts)
    local notify_level = {
      [vim.log.levels.DEBUG] = "DEBUG",
      [vim.log.levels.ERROR] = "ERROR",
      [vim.log.levels.INFO] = "INFO",
      [vim.log.levels.TRACE] = "TRACE",
      [vim.log.levels.WARN] = "WARN",
      [vim.log.levels.OFF] = "OFF",
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
      opts.title = opts.title:sub(1, 20).."..."..opts.title:sub(-20, -1)
    end

    local lines

    if msg then
      lines = {}

      for _, line in ipairs(vim.split(msg, "\n")) do
        for j = 1, #line, max_len do
          table.insert(lines, line:sub(j, j + max_len - 1))
        end
      end
    end

    if not opts.replace then
      local job = require'plenary.job':new {
        args = { vim.fn.expand"~/.dotfiles/scripts/bell" },
        command = "sh",
        detached = true,
      }
      job:start()
    end

    return require'notify'(lines, notify_level[level], opts)
  end
end
