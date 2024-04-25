return {
  config = function()
    require'leap'.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }
    require'leap'.opts.labels = 'asdfghjkl;qwertyuiopzxcvbnm'
    require'leap'.opts.safe_labels = 'sfnut'
    require'leap'.opts.special_keys.prev_target = '<backspace>'
    require'leap'.opts.special_keys.prev_group = '<backspace>'
  end,
}
