my_debugger_callbacks {
  dart = {
    continue = function()
      vim.notify(
        "Detecting devices...",
        vim.log.levels.INFO,
        { title = "Flutter tools" }
      )
      vim.cmd[[FlutterDevices]]
    end,
    restart = function()
      vim.cmd[[FlutterRestart]]
    end,
    terminate = function()
      vim.cmd[[FlutterQuit]]
    end,
  },
}
