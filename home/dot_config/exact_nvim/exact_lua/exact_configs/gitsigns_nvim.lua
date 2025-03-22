return {
  config = function()
    local signs = {
      add = { text = '┃' },
      change = { text = '┃' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '┃' },
      untracked = { text = '┃' },
    }
    require 'gitsigns'.setup {
      current_line_blame = false,
      current_line_blame_formatter = "  <author_time:%R> - <summary>",
      current_line_blame_opts = {
        ignore_whitespace = true,
        virt_text_pos = 'eol',
      },
      max_file_length = 9000,
      signs = signs,
      signs_staged = signs,
    }
  end,
}
