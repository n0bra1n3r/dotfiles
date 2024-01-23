return {
  config = function()
    require 'nvim-treesitter.install'.prefer_git = true
    require 'nvim-treesitter.install'.compilers = { "clang", "gcc" }

    require'nvim-treesitter.configs'.setup {
      ensure_installed = {
        'bash',
        'dart',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'graphql',
        'kotlin',
        'lua',
        'nim',
        'nim_format_string',
        'norg',
        'python',
        'swift',
      },
      highlight = {
        enable = true,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 999
        end,
      },
      matchup = {
        enable = true,
        disable_virtual_text = { 'nim' },
      },
      refactor = {
        highlight_definitions = {
          enable = true,
          clear_on_cursor_move = true,
        },
        navigation = {
          enable = true,
          keymaps = {
            goto_next_usage = '<M-*>',
            goto_previous_usage = '<M-#>',
          },
        },
        smart_rename = {
          enable = false,
        },
      },
    }
  end,
}
