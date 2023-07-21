my_debugger_callbacks {
  dart = {
    continue = function(state, default_fn)
      if state == 1 then
        vim.notify(
          "Detecting devices...",
          vim.log.levels.INFO,
          { title = "Flutter tools" }
        )
        vim.cmd[[FlutterDevices]]
      else
        default_fn()
      end
    end,
    restart = function()
      vim.cmd[[FlutterRestart]]
      vim.notify(
        "Restarted application",
        vim.log.levels.INFO,
        { title = "Flutter tools" }
      )
    end,
    terminate = function()
      vim.cmd[[FlutterQuit]]
    end,
  },
}
