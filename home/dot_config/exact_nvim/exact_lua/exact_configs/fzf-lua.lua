return {
  config = function()
    local actions = require'fzf-lua.actions'

    local function map(lhs, rhs)
      vim.api.nvim_buf_set_keymap(0, 't', lhs, rhs, { silent = true })
    end

    require'fzf-lua'.setup {
      dap = {
        breakpoints = {
          winopts = {
            height = 0.50,
            width = 0.30,
            preview = {
              layout = 'vertical',
              wrap = 'nowrap'
            },
          },
        },
      },
      files = {
        cmd = vim.o.grepprg..' --files',
      },
      keymap = {
        builtin = {},
        fzf = {
          ['ctrl-d'] = 'preview-half-page-down',
          ['ctrl-u'] = 'preview-half-page-up',
          ['tab'] = 'down',
        },
      },
      winopts = {
        border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
        height = 0.85,
        width = 0.80,
        on_create = function()
          for _, mapping in ipairs(vim.api.nvim_get_keymap('t')) do
            map(mapping.lhs, [[<nop>]])
          end
          -- override default terminal keymaps
          map([[<C-Tab>]], [[<Down>]])
          map([[<C-S-Tab>]], [[<Up>]])
          map([[<S-Tab>]], [[<Up>]])
          map([[<M-j>]], [[<Down>]])
          map([[<M-k>]], [[<Up>]])
        end,
        preview = {
          default = 'bat',
          horizontal = 'right:60%',
          layout = 'horizontal',
          vertical = 'up:60%',
          wrap = 'wrap',
        },
      },
    }
  end
}
