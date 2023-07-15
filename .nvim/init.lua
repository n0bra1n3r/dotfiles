my_autocmds {
  { "BufWritePost",
    pattern = "**/chezmoi/home/**",
    callback = function(args)
      local src = vim.fn.fnamemodify(args.file, ":~:.")
      local cmd = [[chezmoi apply --exclude=scripts --force --source-path "%s"]]
      vim.notify(
        ("Applying config at '%s'..."):format(src),
        "INFO",
        { title = "chezmoi" }
      )
      fn.run_command(cmd:format(src))
    end,
  },
}
