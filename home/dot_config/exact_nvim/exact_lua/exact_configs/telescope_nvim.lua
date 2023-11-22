return {
  config = function()
    require'telescope'.setup {
      defaults = require'telescope.themes'.get_dropdown {
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        history = false,
        mappings = {
          i = {
            ['<Esc>'] = require'telescope.actions'.close,
            ['<M-j>'] = require'telescope.actions'.move_selection_next,
            ['<M-k>'] = require'telescope.actions'.move_selection_next,
            ['<S-Tab>'] = require'telescope.actions'.move_selection_previous,
            ['<Tab>'] = require'telescope.actions'.move_selection_next,
          },
        },
        preview = {
          check_mime_type = true,
        },
      },
    }
  end,
}
