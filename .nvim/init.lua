my_autocmds {
  { "BufWritePost",
    pattern = "**/chezmoi/home/**",
    callback = function(args)
      fn.run_command('chezmoi', {
        'apply',
        '--exclude=scripts',
        '--force',
        '--source-path',
        vim.fn.fnamemodify(args.file, ":~:."),
      })
    end,
  },
}
