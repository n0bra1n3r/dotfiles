return {
  config = function()
    require 'which-key'.setup {
      preset = "modern",
      plugins = {
        spelling = {
          enabled = false,
        },
      },
      show_help = false,
      show_keys = false,
      triggers = {
        { '<auto>',   mode = 'nxso' },
        { '<leader>', mode = { 'n', 'v' } },
      },
      win = {
        border = 'single',
        padding = { 0, 0 },
        title = false,
      },
    }
    require 'which-key'.add {
      { '<leader>a', group = "AI" },
      { '<leader>b', group = "Bookmarks" },
      { '<leader>f', group = "File" },
      { '<leader>g', group = "Git" },
      { '<leader>i', group = "Issues" },
      { '<leader>p', group = "Packages" },
      { '<leader>q', group = "Quickfix" },
    }
  end,
}
