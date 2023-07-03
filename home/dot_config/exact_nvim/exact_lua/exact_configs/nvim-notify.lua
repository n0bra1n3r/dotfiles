function plug.config()
  require'notify'.setup {
    fps = 4,
    render = "default",
    stages = "static",
  }

  vim.notify = require'notify'
end
