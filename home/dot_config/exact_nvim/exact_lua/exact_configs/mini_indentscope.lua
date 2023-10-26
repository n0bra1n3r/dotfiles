return {
  config = function()
    vim.b.miniindentscope_disable = #vim.bo.buftype > 0

    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('conf_mini_indentscope', { clear = true }),
      callback = fn.vim_defer(function()
        vim.b.miniindentscope_disable = #vim.bo.buftype > 0
      end),
    })

    require'mini.indentscope'.setup {
      draw = {
        animation = require'mini.indentscope'.gen_animation.none(),
      },
      mappings = {
        object_scope = '',
        object_scope_with_border = '',
      },
      options = {
        border = 'top',
        try_as_border = true,
      },
      symbol = '·',
    }
  end,
}
