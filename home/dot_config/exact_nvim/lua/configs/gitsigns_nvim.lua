function plug.config()
  require"gitsigns".setup {
    current_line_blame = true,
    current_line_blame_formatter = " <author_time:%Y-%m-%d> - <summary>",
    current_line_blame_opts = {
      virt_text_pos = "right_align",
      ignore_whitespace = true,
    },
  }
end
