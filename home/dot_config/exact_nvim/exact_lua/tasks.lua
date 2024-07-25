-- vim: fcl=all fdm=marker fdl=0 fen

--{{{ Helpers
local task
task = function(def)
  local p = 90
  task = function(d)
    p = p + 1
    d.priority = p
    return d
  end
  return task(def)
end
--}}}

my_tasks {
  ["Generate table of contents"] = task { --{{{
    cond = function()
      return vim.bo.filetype == 'markdown'
    end,
    func = function()
      vim.cmd.MDInsertToc()
    end,
  },                                  --}}}
  ["Generate test coverage"] = task { --{{{
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    cmd = 'flutter',
    args = {
      'test',
      '--coverage',
    },
    deps = { [[Show test coverage]] },
  },                              --}}}
  ["Show test coverage"] = task { --{{{
    cond = function()
      return vim.fn.filereadable('coverage/lcov.info') == 1
    end,
    func = function()
      require 'coverage'.load()
      require 'coverage'.summary()
      require 'coverage'.show()
    end,
    notify = false,
  },                              --}}}
  ["Open iOS workspace"] = task { --{{{
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    func = function()
      if vim.fn.isdirectory('./ios/Runner.xcworkspace') == 1 then
        vim.ui.open('./ios/Runner.xcworkspace')
        vim.notify(
          "Opening iOS workspace...",
          vim.log.levels.INFO,
          { title = "Flutter tools" }
        )
      else
        vim.notify(
          "No iOS workspace found!",
          vim.log.levels.WARN,
          { title = "Flutter tools" }
        )
      end
    end,
    notify = false,
  },                                --}}}
  ["Open Android project"] = task { --{{{
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    func = function()
      if vim.fn.filereadable('./android/app/build.gradle') == 1 then
        vim.fn.system { 'open', './android', '-a', '/Applications/Android Studio.app' }
        vim.notify(
          "Opening Android project...",
          vim.log.levels.INFO,
          { title = "Flutter tools" }
        )
      else
        vim.notify(
          "No Android project found!",
          vim.log.levels.WARN,
          { title = "Flutter tools" }
        )
      end
    end,
    notify = false,
  },                         --}}}
  ["Select device"] = task { --{{{
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.g.dap_no_run_on_select_device = true
      vim.g.flutter_current_device = nil

      require 'flutter-tools.devices'.list_devices()
    end,
    notify = false,
  },                        --}}}
  ["Run profiler"] = task { --{{{
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      local url = require 'flutter-tools.dev_tools'.get_profiler_url()
      if url then
        vim.ui.open(url)
      end
    end,
    notify = false,
  },                      --}}}
  ["Hot reload"] = task { --{{{
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function()
      require 'flutter-tools.commands'.reload()
    end,
    notify = false,
  },                          --}}}
  ["Debug continue"] = task { --{{{
    cond = function()
      return fn.is_debug_mode() and vim.g.project_type == 'flutter'
    end,
    func = function(args)
      if not args.state or args.state == 1 then
        require 'flutter-tools.commands'.run()
      else
        require 'dap'.continue()
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
  },                         --}}}
  ["Debug restart"] = task { --{{{
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      require 'flutter-tools.commands'.restart()
    end,
    notify = false,
  },
  ["Debug terminate"] = task {
    cond = function()
      return fn.is_debugging() and vim.g.project_type == 'flutter'
    end,
    func = function()
      require 'flutter-tools.commands'.quit()
    end,
    notify = false,
  },                                         --}}}
  ["Install project configuration"] = task { --{{{
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
  },                         --}}}
  ["Reload editor"] = task { --{{{
    func = function()
      vim.cmd.windo('edit')
    end,
  }, --}}}
}
