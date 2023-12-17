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
  ["Run in emulator"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.g.flutter_current_config = nil
      vim.g.flutter_current_device = nil

      require'flutter-tools.devices'.list_emulators()
    end,
    notify = false,
    priority = 93,
  },
  ["Run on device"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.g.flutter_current_config = nil
      vim.g.flutter_current_device = nil

      require'flutter-tools.devices'.list_devices()
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
      require'flutter-tools.commands'.reload()
    end,
    notify = false,
    priority = 96,
  },
  ["Debug continue"] = {
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function(args)
      if not args.state or args.state == 1 then
        require'flutter-tools.commands'.run()
      else
        require'dap'.continue()
      end
    end,
    notify = false,
    params = {
      state = {
        desc = "Current debug state",
        optional = true,
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
      require'flutter-tools.commands'.restart()
    end,
    notify = false,
    priority = 98,
  },
  ["Debug terminate"] = {
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      require'flutter-tools.commands'.quit()
    end,
    notify = false,
    priority = 99,
  },
  ["Install project config"] = {
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
        fn.save_as_workspace_config)
    end,
    notify = false,
    priority = 100,
  },
}
