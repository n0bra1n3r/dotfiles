return {
  config = function()
    require'flash'.setup {
      labels = 'asdfghjklqwertyuiopzxcvbnm',
      search = {
        multi_window = false,
      },
      label = {
        uppercase = false,
        rainbow = {
          enabled = true,
        },
      },
      modes = {
        char = {
          label = { exclude = 'jkliardcy' },
          multi_line = false,
          keys = { 'f', 'F', 't', 'T', [';'] = 'h', ',' },
          char_actions = function(motion)
            return {
              h = 'next',
              [','] = 'prev',
              [motion:lower()] = 'next',
              [motion:upper()] = 'prev',
            }
          end,
        },
      },
    }
  end,
}
