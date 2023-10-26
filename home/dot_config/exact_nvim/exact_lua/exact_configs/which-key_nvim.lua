return {
  config = function()
    require'which-key'.setup {
      window = {
        border = "single",
        margin = { 0, 0, 0, 0 },
        padding = { 0, 0, 0, 0 },
        position = "top",
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
      },
    }, { mode = "n" })
    require'which-key'.register({
      ["<leader>"] = {
        a = { name = "AI" },
      },
    }, { mode = "x" })
  end,
}
