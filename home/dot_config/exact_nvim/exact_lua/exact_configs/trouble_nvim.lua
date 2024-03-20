return {
  config = function()
    require'trouble'.setup {
      action_keys = {
        close = [[<Esc>]],
        cancel = {},
        jump = { [[<CR>]], [[<2-LeftMouse>]] },
        open_split = { [[<M-->]] },
        open_vsplit = { [[<M-\>]] },
        open_tab = { [[<M-=>]] },
      },
      auto_close = true,
      auto_open = true,
      padding = false,
      use_diagnostic_signs = true,
    }
  end,
}
