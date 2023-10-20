return {
  config = function()
    require'flutter-tools'.setup {
      debugger = {
        enabled = true,
        exception_breakpoints = 'default',
        register_configurations = function(paths)
          local my_launchers =
            my_config.launchers and
            my_config.launchers.dart
          local default_launcher = {
            type = 'dart',
            dartSdkPath = paths.dart_sdk,
            flutterSdkPath = paths.flutter_sdk,
            program = '${workspaceFolder}/lib/main.dart',
            cwd = '${workspaceFolder}',
          }
          if my_launchers then
            local launchers = vim.deepcopy(my_launchers)
            for i, launcher in ipairs(launchers) do
              launchers[i] = vim.tbl_extend(
                'keep',
                launcher,
                default_launcher
              )
            end
            require'dap'.configurations.dart = launchers
          else
            require'dap'.configurations.dart = {
              vim.tbl_extend('keep', {
                request = 'launch',
                name = 'Launch app',
              }, default_launcher),
              vim.tbl_extend('keep', {
                request = 'attach',
                name = 'Connect to running app',
              }, default_launcher),
            }
          end
        end,
        run_via_dap = true,
      },
      dev_log = {
        enabled = false,
      },
      dev_tools = {
        autostart = true,
      },
      fvm = true,
      lsp = {
        settings = {
          renameFilesWithClasses = 'always',
          analysisExcludedFolders = {
            '.dart_tool',
            vim.fn.expand('~/.pub-cache/'),
            vim.fn.expand('~/.fvm/'),
          },
          completeFunctionCalls = true,
          experimentalRefactors = true,
        },
      },
      ui = {
        border = 'single',
      },
    }

    -- FIX: Hack to fix current_device
    local select_device_fn = require'flutter-tools.devices'.select_device
    require'flutter-tools.devices'.select_device = function(device, args)
      vim.g.flutter_current_device = device
      select_device_fn(device, args)
    end

    require'telescope'.load_extension('flutter')
  end,
}
