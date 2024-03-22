return {
  config = function()
    require'which-key'.setup {
      layout = {
        align = 'center',
      },
      show_help = false,
      show_keys = false,
      window = {
        border = 'single',
        margin = { 0, 0, 0, 0 },
        padding = { 0, 0, 0, 0 },
        position = 'top',
      },
    }
    require'which-key'.register({
      ["<leader>"] = {
        a = { name = "AI" },
        b = { name = "Bookmarks" },
        d = { name = "Debug" },
        f = { name = "File" },
        g = { name = "Git" },
        i = { name = "Issues" },
        p = { name = "Packages" },
        q = { name = "Quickfix" },
      },
    }, { mode = "n" })
  end,
}
