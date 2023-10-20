return {
  config = function()
    require'gitsigns'.setup {
      _signs_staged_enable = true,
      current_line_blame = true,
      current_line_blame_formatter = "  <author_time:%R> - <summary>",
      current_line_blame_opts = {
        ignore_whitespace = true,
        virt_text_pos = 'eol',
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
  end,
}
