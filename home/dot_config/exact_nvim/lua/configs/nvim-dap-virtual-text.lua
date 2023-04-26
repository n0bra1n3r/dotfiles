function plug.config()
  require'nvim-dap-virtual-text'.setup {
    commented = true,
    highlight_changed_variables = false,
  }
end
