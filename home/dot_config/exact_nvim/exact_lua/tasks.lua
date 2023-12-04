my_tasks {
  ["Generate test coverage"] = {
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    cmd = 'fvm',
    args = {
      'flutter',
      'test',
      '--coverage',
    },
    deps = { [[Show test coverage]] },
    priority = 91,
  },
  ["Show test coverage"] = {
    func = function()
      require'coverage'.load()
      require'coverage'.summary()
    end,
    notify = false,
    priority = 92,
  },
  ["Select emulator"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.g.flutter_current_config = nil
      vim.g.flutter_current_device = nil

      vim.cmd[[FlutterEmulators]]
    end,
    notify = false,
    priority = 93,
  },
  ["Select device"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.g.flutter_current_config = nil
      vim.g.flutter_current_device = nil

      vim.cmd[[FlutterDevices]]
      vim.notify(
        "Detecting Devices...",
        vim.log.levels.INFO,
        { title = "Flutter tools" }
      )
    end,
    notify = false,
    priority = 94,
  },
  ["Run profiler"] = {
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      local url = require'flutter-tools.dev_tools'.get_profiler_url()
      if url then
        fn.open_in_os{ url }
      end
    end,
    notify = false,
    priority = 95,
  },
  ["Hot reload"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterReload]]
    end,
    notify = false,
    priority = 96,
  },
  ["Debug continue"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function(args)
      if args.state == 1 then
        vim.cmd[[FlutterRun]]
      else
        require'dap'.continue()
      end
    end,
    notify = false,
    params = {
      state = {
        desc = "Current debug state",
        type = 'number',
      },
    },
    priority = 97,
  },
  ["Debug restart"] = {
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterRestart]]
      vim.notify(
        "Restarted application",
        vim.log.levels.INFO,
        { title = "Flutter tools" }
      )
    end,
    notify = false,
    priority = 98,
  },
  ["Debug terminate"] = {
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterQuit]]
    end,
    notify = false,
    priority = 99,
  },
  ["Install project configuration"] = {
    cond = function()
      return not fn.has_workspace_config()
    end,
    func = function()
      vim.ui.select(
        vim.fn.glob('~/.dotfiles/project_configs/*.lua', true, true),
        {
          prompt = " 󰆴 Select project type: ",
          dressing = {
            relative = 'editor',
          },
          format_item = function(item)
            return vim.fn.join(vim.split(vim.fn.fnamemodify(item, ':t:r'), '-'))
          end,
        },
        function(choice)
          if choice and #choice > 0 then
            local workspace_path = fn.get_workspace_dir()
            local workspace_conf = workspace_path..'/'..vim.g.local_config_file_name
            fn.save_workspace()
            vim.fn.writefile(vim.fn.readfile(choice), workspace_conf)
            pcall(require'config-local'.trust, workspace_conf)
          end
        end)
    end,
    notify = false,
    priority = 100,
  },
}
