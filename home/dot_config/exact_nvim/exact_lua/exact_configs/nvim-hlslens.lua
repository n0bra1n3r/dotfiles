return {
  config = function()
    require'hlslens'.setup()

    vim.api.nvim_set_keymap("n", "n",
      [[<cmd>execute("normal! " . v:count1 . "n")<CR><cmd>lua require'hlslens'.start()<CR>]],
      { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "N",
      [[<cmd>execute("normal! " . v:count1 . "N")<CR><cmd>lua require'hlslens'.start()<CR>]],
      { noremap = true, silent = true })

    vim.api.nvim_set_keymap("n", "*", [[<Plug>(asterisk-z*)<cmd>lua require'hlslens'.start()<CR>]], {})
    vim.api.nvim_set_keymap("n", "#", [[<Plug>(asterisk-z#)<cmd>lua require'hlslens'.start()<CR>]], {})
    vim.api.nvim_set_keymap("n", "g*", [[<Plug>(asterisk-gz*)<cmd>lua require'hlslens'.start()<CR>]], {})
    vim.api.nvim_set_keymap("n", "g#", [[<Plug>(asterisk-gz#)<cmd>lua require'hlslens'.start()<CR>]], {})

    vim.api.nvim_set_keymap("x", "*", [[<Plug>(asterisk-z*)<cmd>lua require'hlslens'.start()<CR>]], {})
    vim.api.nvim_set_keymap("x", "#", [[<Plug>(asterisk-z#)<cmd>lua require'hlslens'.start()<CR>]], {})
    vim.api.nvim_set_keymap("x", "g*", [[<Plug>(asterisk-gz*)<cmd>lua require'hlslens'.start()<CR>]], {})
    vim.api.nvim_set_keymap("x", "g#", [[<Plug>(asterisk-gz#)<cmd>lua require'hlslens'.start()<CR>]], {})
  end,
}
