function plug.config()
  require'treesitter-context'.setup {
    max_lines = 1,
    multiline_threshold = 1,
    separator = '─',
  }

  vim.api.nvim_set_hl(0, 'TreesitterContext', { link = 'Normal' })
end
