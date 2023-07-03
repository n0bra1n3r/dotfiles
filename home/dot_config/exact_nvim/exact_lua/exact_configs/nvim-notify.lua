function plug.config()
  require'notify'.setup {
    fps = 4,
    stages = "static",
  }

  vim.notify = require'notify'
end
