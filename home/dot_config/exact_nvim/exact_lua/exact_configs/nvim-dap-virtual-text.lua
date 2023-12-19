return {
  config = function()
    require'nvim-dap-virtual-text'.setup {
      all_references = true,
      display_callback = function(variable)
        return variable.name..' = '..variable.value
      end,
      highlight_new_as_changed = true,
      virt_text_win_col = 80,
    }
  end,
}
