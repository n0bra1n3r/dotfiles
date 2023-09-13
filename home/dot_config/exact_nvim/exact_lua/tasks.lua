my_tasks {
  ["Debug continue 1"] = {
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterDevices]]
      vim.notify(
        "Detecting devices...",
        vim.log.levels.INFO,
        { title = "Flutter tools" }
      )
    end,
    notify = false,
    priority = 98,
  },
  ["Debug restart"] = {
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterRestart]]
      vim.notify(
        "Restarted application",
        vim.log.levels.INFO,
        { title = "Flutter tools" }
      )
    end,
    notify = false,
    priority = 99,
  },
  ["Debug terminate"] = {
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterQuit]]
    end,
    notify = false,
    priority = 100,
  },
}
