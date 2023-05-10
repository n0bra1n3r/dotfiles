function plug.config()
  require"gitsigns".setup {
    attach_to_untracked = false,
    current_line_blame = true,
    current_line_blame_formatter = " <author_time:%R> - <summary>",
    current_line_blame_opts = {
      virt_text_pos = "right_align",
      ignore_whitespace = true,
    },
    signs = {
      add = { text = '┃' },
      change = { text = '┃' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '┃' },
      untracked = { text = '┃' },
    },
  }

  vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GitsignsDelete" })
end
