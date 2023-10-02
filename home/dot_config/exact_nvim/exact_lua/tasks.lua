my_tasks {
  ["Debug continue"] = {
    cond = function()
      return vim.g.project_type == 'flutter'
    end,
    func = function(args)
      if args.state == 1 then
        local has_device =
          require'flutter-tools.commands'.current_device() ~= nil
        if args.mods == [[s   ]] or not has_device then
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
      return vim.g.project_type == 'flutter'
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
      return vim.g.project_type == 'flutter'
    end,
    func = function()
      vim.cmd[[FlutterQuit]]
    end,
    notify = false,
    priority = 100,
  },
}
