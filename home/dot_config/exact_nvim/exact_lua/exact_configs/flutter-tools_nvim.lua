function plug.config()
  require'flutter-tools'.setup {
    debugger = {
      enabled = true,
      exception_breakpoints = {
        "uncaught",
      },
      register_configurations = function()
        -- no-op so project launcher config is not overwritten by plugin
      end,
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
