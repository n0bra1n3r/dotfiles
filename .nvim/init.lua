my_autocmds {
  { 'BufWritePost',
    pattern = '*/chezmoi/home/*',
    callback = function(args)
      fn.run_task([[Apply config]], {
        '--exclude=scripts',
        '--force',
        '--source-path',
        vim.fn.fnamemodify(args.file, ':~:.'),
      })
    end,
  },
}

my_tasks {
  ["Apply config"] = {
    cmd = 'chezmoi',
    args = {
      'apply',
    },
  }
}
