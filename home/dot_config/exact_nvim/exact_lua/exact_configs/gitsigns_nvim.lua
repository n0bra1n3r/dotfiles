return {
  config = function()
    require'gitsigns'.setup {
      current_line_blame = false,
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
