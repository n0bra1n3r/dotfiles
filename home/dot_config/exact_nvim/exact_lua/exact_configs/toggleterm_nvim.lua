return {
  config = function()
    require'toggleterm'.setup {
      autochdir = false,
      direction = 'float',
      on_create = function(t)
        vim.wo[t.window].foldcolumn = '0'
        vim.wo[t.window].signcolumn = 'no'
      end,
      open_mapping = nil,
      shade_terminals = false,
      -- required to avoid '\r\n' for `chansend` in git bash
      shell = 'powershell',
    }

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('conf_toggleterm', { clear = true }),
      pattern = 'toggleterm',
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', [[gf]], [[<cmd>tabe <cfile><CR>]],
          { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', [[<C-c>]], [[<Nop>]],
          { noremap = true, silent = true })
      end,
    })
  end,
}
