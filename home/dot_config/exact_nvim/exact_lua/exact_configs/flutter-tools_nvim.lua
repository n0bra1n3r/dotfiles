-- vim: fcl=all fdm=marker fdl=0 fen

--{{{ Helpers
local get_device_entries
get_device_entries = function(on_update)
  local entries = {}
  get_device_entries = function(cb)
    require'flutter-tools.executable'.flutter(function(cmd)
      local job = require'plenary.job':new {
        command = cmd,
        args = { 'devices' },
      }
      job:after_success(vim.schedule_wrap(function(j)
        local new_entries = require'flutter-tools.devices'.to_selection_entries(j:result(), 2)
        if cb and not vim.deep_equal(new_entries, entries) then
          cb(new_entries)
        end
        entries = new_entries
      end))
      job:after_failure(vim.schedule_wrap(function(j)
        local result = j:result()
        local message = not vim.tbl_isempty(result)
          and result
          or j:stderr_result()
        if cb then cb(nil) end
        local ui = require'flutter-tools.ui'
        ui.notify(table.concat(message, "\n"), vim.ui.ERROR)
      end))
      job:start()
    end)
    return entries
  end
  return get_device_entries(on_update)
end
--}}}

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
            program = 'lib/main.dart',
            cwd = '${workspaceFolder}',
          }
          if my_launchers then
            local launchers = vim.deepcopy(my_launchers)
            for i, launcher in ipairs(launchers) do
              if launcher.condition and not launcher.condition() then
                launchers[i] = nil
              else
                launchers[i] = vim.tbl_extend(
                  'keep',
                  launcher,
                  default_launcher
                )
              end
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
      flutter_lookup_cmd = vim.fn.expand[[~/.dotfiles/scripts/find-flutter.sh]],
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
            vim.fn.expand('~/.puro/'),
          },
          completeFunctionCalls = true,
          experimentalRefactors = true,
        },
      },
      root_patterns = { '.git', 'pubspec.yaml', 'main.dart' },
      ui = {
        border = 'single',
      },
    }

    require'flutter-tools.dap'.setup(require'flutter-tools.config')

    --{{{ Lazy load device menu
    require'flutter-tools.devices'.list_devices = function()
      local progress = require'fidget.progress'
      local handle = progress.handle.create {
        title = "Flutter tools",
        message = "Detecting Devices...",
      }

      local entries
      entries = get_device_entries(function(new_entries)
        if #entries > 0 and new_entries then
          handle:report {
            title = "Flutter tools",
            message = "Updated device list!",
          }
        end
        handle:finish()

        if #entries == 0 then
          require'flutter-tools.ui'.select {
            title = "Flutter devices",
            lines = new_entries,
            on_select = require'flutter-tools.devices'.select_device,
          }
        end
      end)
      if #entries > 0 then
        require'flutter-tools.ui'.select {
          title = "Flutter devices",
          lines = entries,
          on_select = require'flutter-tools.devices'.select_device,
        }
      end
    end
    --}}}
    --{{{ Hack to set current_device
    local select_device_fn = require'flutter-tools.devices'.select_device
    require'flutter-tools.devices'.select_device = function(device, args)
      vim.g.flutter_current_device = device
      if vim.g.dap_no_run_on_select_device then
        vim.g.dap_no_run_on_select_device = false
      else
        select_device_fn(device, args)
      end
    end
    --}}}
    --{{{ Hack to set dap_current_config
    local pick_if_many_fn = require'dap.ui'.pick_if_many
    local run_fn = require'dap'.run
    require'dap.ui'.pick_if_many = function(l, p, fmt_fn, ...)
      local config = vim.g.dap_current_config
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
        vim.g.dap_current_config = config
        local device = vim.g.flutter_current_device
        if device then
          config.args = vim.list_extend(config.args or {}, {
            '--device-id',
            device.id,
          })
        end
      else
        vim.g.dap_current_config = nil
      end
      run_fn(config, ...)
    end
    --}}}
  end,
}
