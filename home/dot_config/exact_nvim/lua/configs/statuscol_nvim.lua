function plug.config()
  require'statuscol'.setup {
    relculright = true,
    segments = {
      { text = { " " } },
      {
        sign = { name = { ".*" }, auto = true },
        click = "v:lua.ScSa",
      },
      {
        text = { require'statuscol.builtin'.lnumfunc, " " },
        click = "v:lua.ScLa",
      },
      {
        text = { require'statuscol.builtin'.foldfunc, " " },
        click = "v:lua.ScFa",
      },
    },
  }
end
