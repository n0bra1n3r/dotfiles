local M = {}

function M.config()
  require"hlslens".setup()

  vim.api.nvim_set_keymap("n", "n",
    [[<Cmd>execute("normal! " . v:count1 . "n")<CR><Cmd>lua require"hlslens".start()<CR>]],
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "N",
    [[<Cmd>execute("normal! " . v:count1 . "N")<CR><Cmd>lua require"hlslens".start()<CR>]],
    { noremap = true, silent = true })

  vim.api.nvim_set_keymap("n", "*", [[<Plug>(asterisk-z*)<Cmd>lua require"hlslens".start()<CR>]], {})
  vim.api.nvim_set_keymap("n", "#", [[<Plug>(asterisk-z#)<Cmd>lua require"hlslens".start()<CR>]], {})
  vim.api.nvim_set_keymap("n", "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require"hlslens".start()<CR>]], {})
  vim.api.nvim_set_keymap("n", "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require"hlslens".start()<CR>]], {})

  vim.api.nvim_set_keymap("x", "*", [[<Plug>(asterisk-z*)<Cmd>lua require"hlslens".start()<CR>]], {})
  vim.api.nvim_set_keymap("x", "#", [[<Plug>(asterisk-z#)<Cmd>lua require"hlslens".start()<CR>]], {})
  vim.api.nvim_set_keymap("x", "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require"hlslens".start()<CR>]], {})
  vim.api.nvim_set_keymap("x", "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require"hlslens".start()<CR>]], {})
end

return M
