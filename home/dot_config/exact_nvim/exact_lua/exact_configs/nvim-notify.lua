function plug.config()
  require'notify'.setup {
    fps = 1,
    stages = "static",
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
    require'notify'(msg, notify_level[level], opts)
  end
end
