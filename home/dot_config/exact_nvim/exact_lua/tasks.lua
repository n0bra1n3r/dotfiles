my_tasks {
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
    priority = 97,
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
      mods = {
        desc = "Modifier keys",
        optional = true,
        type = 'string',
      },
      state = {
        desc = "Current debug state",
        type = 'number',
      },
    },
    priority = 98,
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
    priority = 99,
  },
  ["Debug terminate"] = {
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterQuit]]
    end,
    notify = false,
    priority = 100,
  },
}
