return {
  config = function()
    require'treesitter-context'.setup {
      max_lines = 1,
      multiline_threshold = 1,
      separator = '─',
    }
  end,
}
