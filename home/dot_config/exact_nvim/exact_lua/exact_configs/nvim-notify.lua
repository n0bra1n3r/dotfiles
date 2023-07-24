function plug.config()
  require'notify'.setup {
    fps = 1,
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

    return require'notify'(msg, notify_level[level], opts)
  end
end
