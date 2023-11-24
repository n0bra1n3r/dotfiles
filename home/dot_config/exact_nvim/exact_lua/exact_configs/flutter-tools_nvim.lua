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
        color = {
          enabled = true,
        },
        on_attach = function(client)
          client.server_capabilities.semanticTokensProvider = nil
        end,
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

    -- FIX: Hack to set current_device
    local select_device_fn = require'flutter-tools.devices'.select_device
    require'flutter-tools.devices'.select_device = function(device, args)
      vim.g.flutter_current_device = device
      select_device_fn(device, args)
    end

    -- FIX: Hack to set current_config
    local pick_if_many_fn = require'dap.ui'.pick_if_many
    local run_fn = require'dap'.run
    require'dap.ui'.pick_if_many = function(l, p, fmt_fn, ...)
      local config = vim.g.flutter_current_config
      if config then
        local device = vim.g.flutter_current_device
        if device then
          config.args = vim.list_extend(config.args or {}, {
            '--device-id',
            device.id,
          })
        end
        run_fn(config)
      else
        pick_if_many_fn(
          l,
          p,
          function(item)
            if item.args then
              return fmt_fn(item)
            else
              return ('%s : %s'):format(item.name, item.program or item.cwd)
            end
          end,
          ...
        )
      end
    end
    require'dap'.run = function(config, ...)
      if config.dartSdkPath and config.flutterSdkPath then
        vim.g.flutter_current_config = config
      else
        vim.g.flutter_current_config = nil
      end
      run_fn(config, ...)
    end

    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('conf_flutter_tools', { clear = true }),
      pattern = 'ConfigLocalFinished',
      callback = function()
        if fn.has_local_config() then
          if vim.g.project_type == 'flutter' then
            vim.api.nvim_set_keymap('n', [[<leader>fa]], [[]], {
              callback = function()
                fn.open_in_os{ './android', '-a', '/Applications/Android Studio.app' }
                vim.notify(
                  "Opening Android project...",
                  vim.log.levels.INFO,
                  { title = "Flutter tools" }
                )
              end,
              desc = "Open Android project",
              noremap = true,
              silent = true,
            })
            vim.api.nvim_set_keymap('n', [[<leader>fi]], [[]], {
              callback = function()
                fn.open_in_os{ './ios/Runner.xcworkspace' }
                vim.notify(
                  "Opening iOS project...",
                  vim.log.levels.INFO,
                  { title = "Flutter tools" }
                )
              end,
              desc = "Open iOS project",
              noremap = true,
              silent = true,
            })
          end
        end
      end,
    })
  end,
}
