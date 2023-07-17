function plug.config()
  require'flutter-tools'.setup {
    debugger = {
      enabled = true,
      exception_breakpoints = {
        "uncaught",
      },
      run_via_dap = true,
    },
    dev_log = {
      enabled = false,
    },
    dev_tools = {
      autostart = true,
    },
    ui = {
      border = "single",
    },
  }
end
