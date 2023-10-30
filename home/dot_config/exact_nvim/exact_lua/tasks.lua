my_tasks {
  ["Run profiler"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      local url = require'flutter-tools.dev_tools'.get_profiler_url()
      if url then
        fn.open_in_os(url)
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
  ["Screenshot clipboard"] = {
    cmd = 'silicon',
    args = {
      '--from-clipboard',
      '--to-clipboard',
    },
    priority = 97,
  },
  ["Debug continue"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function(args)
      if args.state == 1 then
        if args.mods == [[s   ]] or not vim.g.flutter_current_device then
          vim.cmd[[FlutterDevices]]
          vim.notify(
            "Detecting Devices...",
            vim.log.levels.INFO,
            { title = "Flutter tools" }
          )
        else
          vim.cmd[[FlutterRun]]
        end
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
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
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
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterQuit]]
    end,
    notify = false,
    priority = 100,
  },
}
