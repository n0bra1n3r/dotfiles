my_debugger_callbacks {
  dart = {
    continue = function(state, default_fn)
      if state == 1 then
        if not vim.g.flutter_tools_did_choose_device then
          vim.g.flutter_tools_did_choose_device = true

          vim.cmd[[FlutterDevices]]
          vim.notify(
            "Detecting devices...",
            vim.log.levels.INFO,
            { title = "Flutter tools" }
          )
        else
          vim.cmd[[FlutterRun]]
        end
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
