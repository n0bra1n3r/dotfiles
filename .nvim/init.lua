my_autocmds {
  { "BufWritePost",
    pattern = "**/chezmoi/home/**",
    callback = function(args)
      fn.run_task('Apply config', {
        vim.fn.fnamemodify(args.file, ":~:."),
      })
    end,
  },
}

my_tasks {
  ["Apply config"] = {
    cmd = 'chezmoi',
    args = {
      'apply',
      '--exclude=scripts',
      '--force',
      '--source-path',
    },
  }
}
