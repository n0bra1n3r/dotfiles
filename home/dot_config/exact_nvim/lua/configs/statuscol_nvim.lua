function plug.config()
  require'statuscol'.setup {
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
      {
        sign = { name = { "Diagnostic" }, auto = true },
        click = "v:lua.ScSa"
      },
    },
  }
end
