function plug.config()
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
      prompt_prefix = ' ',
    },
    pickers = {
      loclist = {
        fname_width = 9999,
        mappings = {
          i = {
            ['<Tab>'] = function(bufnr)
              require'telescope.actions.set'.edit(bufnr, 'edit')
            end,
            ['<C-S-Tab>'] = require'telescope.actions'.move_selection_previous,
            ['<C-Tab>'] = require'telescope.actions'.move_selection_next,
          },
        },
        path_display = function(_, path)
          return vim.fn.fnamemodify(path, ':~:.')
        end,
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
end
