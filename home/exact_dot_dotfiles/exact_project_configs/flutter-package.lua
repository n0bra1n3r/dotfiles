my_globals {
  project_type = 'flutter',
}

my_autocmds {
  {
    'BufWritePost',
    pattern = { '*.arb' },
    callback = function()
      fn.run_task[[Gen strings]]
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
