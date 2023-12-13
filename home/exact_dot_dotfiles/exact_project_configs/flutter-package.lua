my_globals {
  project_type = 'flutter',
}

my_autocmds {
  {
    'BufNew',
    pattern = { '*.swift' },
    callback = function()
      fn.run_task[[Update iOS example]]
    end,
  },
  {
    'BufWritePost',
    pattern = { '*.arb' },
    callback = function()
      fn.run_task[[Gen strings]]
    end,
  },
  {
    'FileChangedShell',
    pattern = { 'project.pbxproj' },
    callback = function()
      fn.run_task[[Update iOS example]]
    end,
  },
}

my_tasks {
  ["Install dependencies"] = {
    cmd = 'fvm',
    args = {
      'flutter',
      'pub',
      'get',
    },
    deps = { [[Install project configuration]] },
    priority = 1,
  },
  ["Update iOS example"] = {
    cond = function()
      return vim.fn.isdirectory('example/ios')
    end,
    cmd = 'pod',
    args = { 'install' },
    cwd = 'example/ios',
    priority = 2,
  },
  ["Run codegen"] = {
    cmd = 'fvm',
    args = {
      'dart',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    },
    deps = { [[Hot reload]] },
    priority = 52,
  },
  ["Gen strings"] = {
    cmd = 'fvm',
    args = {
      'flutter',
      'gen-l10n',
    },
    priority = 53,
  },
}

my_launchers {
  dart = {
    {
      name = "Launch example",
      cwd = '${workspaceFolder}/example',
      request = 'launch',
    },
  },
}
