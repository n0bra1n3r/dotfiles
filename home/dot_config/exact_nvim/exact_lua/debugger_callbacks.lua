my_debugger_callbacks {
  dart = {
    continue = function()
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
