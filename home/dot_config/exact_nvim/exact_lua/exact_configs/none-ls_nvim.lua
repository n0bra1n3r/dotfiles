return {
  config = function()
    require'null-ls'.setup {
      log_level = 'off',
      sources = {
        require'null-ls'.builtins.formatting.swift_format,
      },
    }
  end,
}
