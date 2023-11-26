return {
  config = function()
    require'telescope'.setup {
      defaults = {
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        history = false,
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            height = 0.85,
            width = 0.80,
            preview_width = 0.60,
            prompt_position = 'top',
          },
          vertical = {
            height = 0.85,
            width = 0.80,
            preview_height = 0.60,
            prompt_position = 'top',
          },
        },
        mappings = {
          i = {
            ['<Esc>'] = require'telescope.actions'.close,
            ['<C-Tab>'] = require'telescope.actions'.move_selection_next,
            ['<C-S-Tab>'] = require'telescope.actions'.move_selection_previous,
            ['<S-Tab>'] = require'telescope.actions'.move_selection_previous,
            ['<Tab>'] = require'telescope.actions'.move_selection_next,
            ['<M-j>'] = require'telescope.actions'.move_selection_next,
            ['<M-k>'] = require'telescope.actions'.move_selection_previous,
          },
        },
        path_display = function(_, path)
          return vim.fn.fnamemodify(path, ':~:.')
        end,
        preview = {
          check_mime_type = true,
        },
        sorting_strategy = 'ascending',
      },
      pickers = {
        loclist = {
          fname_width = 9999,
        },
        lsp_document_symbols = {
          symbols = {
            'method',
            'function',
            'class',
            'interface',
            'module',
            'enum',
            'struct',
          },
        },
      },
    }

    require'telescope'.load_extension('dap')
    require'telescope'.load_extension('fzf')
  end,
}
