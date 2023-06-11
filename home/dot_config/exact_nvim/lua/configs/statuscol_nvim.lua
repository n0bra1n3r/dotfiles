function plug.config()
  require'statuscol'.setup {
    bt_ignore = {
      "help",
      "quickfix",
      "terminal",
    },
    ft_ignore = { "toggleterm" },
    relculright = true,
    segments = {
      { text = { " " } },
      {
        sign = { name = { "Dap" }, auto = true },
        click = "v:lua.ScLa",
      },
      {
        text = { require'statuscol.builtin'.lnumfunc },
        click = "v:lua.ScLa",
      },
      {
        sign = { name = { "GitSigns" }, colwidth = 1 },
        click = "v:lua.ScSa",
      },
      {
        text = { require'statuscol.builtin'.foldfunc },
        click = "v:lua.ScFa"
      },
      { text = { " " } },
    },
  }
end
