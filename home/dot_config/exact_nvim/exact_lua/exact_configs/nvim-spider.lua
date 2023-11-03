return {
  config = function()
    require'spider'.setup{}

    vim.api.nvim_set_keymap('', 'w', [[<cmd>lua require'spider'.motion('w')<CR>]], {})
    vim.api.nvim_set_keymap('', 'e', [[<cmd>lua require'spider'.motion('e')<CR>]], {})
    vim.api.nvim_set_keymap('', 'b', [[<cmd>lua require'spider'.motion('b')<CR>]], {})
    vim.api.nvim_set_keymap('', 'ge', [[<cmd>lua require'spider'.motion('ge')<CR>]], { desc = "Previous end of word" })
  end,
}
