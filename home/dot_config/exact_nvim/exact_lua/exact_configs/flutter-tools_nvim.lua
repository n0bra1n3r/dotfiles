function plug.config()
  require'flutter-tools'.setup {
    debugger = {
      enabled = true,
      exception_breakpoints = {
        "uncaught",
      },
      register_configurations = function(paths)
        local my_launchers =
          my_config.launchers and
          my_config.launchers["dart"]
        if my_launchers then
          local launchers = vim.deepcopy(my_launchers)
          for _, launcher in ipairs(launchers) do
            if not launcher.dart_sdk then
              launcher.dart_sdk = paths.dart_sdk
            end
            if not launcher.flutter_sdk then
              launcher.flutter_sdk = paths.flutter_sdk
            end
          end
          require'dap'.configurations.dart = launchers
        else
          require'dap'.configurations.dart = {
            {
              type = "dart",
              request = "launch",
              name = "Launch app",
              dartSdkPath = paths.dart_sdk,
              flutterSdkPath = paths.flutter_sdk,
              program = "${workspaceFolder}/lib/main.dart",
              cwd = "${workspaceFolder}",
            },
            {
              type = "dart",
              request = "attach",
              name = "Connect to running app",
              dartSdkPath = paths.dart_sdk,
              flutterSdkPath = paths.flutter_sdk,
              program = "${workspaceFolder}/lib/main.dart",
              cwd = "${workspaceFolder}",
            },
          }
        end
      end,
      run_via_dap = true,
    },
    decorations = {
      statusline = {
        app_version = true,
        device = true,
        project_config = true,
      },
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
