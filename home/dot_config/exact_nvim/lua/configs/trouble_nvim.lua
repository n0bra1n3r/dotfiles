function plug.config()
  require'trouble'.setup {
    auto_close = true,
    auto_open = true,
    fold_closed = "",
    fold_open = "",
    use_diagnostic_signs = true,
  }
end
