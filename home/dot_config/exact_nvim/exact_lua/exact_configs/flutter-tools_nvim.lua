function plug.config()
  require'flutter-tools'.setup {
    debugger = {
      enabled = true,
      run_via_dap = true,
      exception_breakpoints = {
        "uncaught",
      },
    },
    dev_log = {
      enabled = false,
    },
    ui = {
      border = "single",
    },
  }
end
