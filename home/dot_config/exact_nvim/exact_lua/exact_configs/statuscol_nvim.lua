function plug.config()
  require'statuscol'.setup {
    bt_ignore = {
      "help",
      "quickfix",
      "terminal",
    },
    clickhandlers = {
      Lnum = function(args)
        if args.button ~= "l" or fn.get_is_debugging() then
          require'statuscol.builtin'.lnum_click(args)
        end
      end,
    },
    ft_ignore = {
      "dapui_scopes",
      "dapui_stacks",
      "dapui_breakpoints",
      "toggleterm"
    },
    relculright = true,
    segments = {
      { text = { " " } },
      {
        sign = { name = { "Dap" } },
        condition = { fn.get_is_debugging },
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
        click = "v:lua.ScFa",
      },
      { text = { " " } },
    },
  }
end
