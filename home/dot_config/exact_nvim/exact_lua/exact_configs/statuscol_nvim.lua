return {
  config = function()
    require'statuscol'.setup {
      bt_ignore = {
        'acwrite',
        'help',
        'nofile',
        'nowrite',
        'prompt',
        'quickfix',
        'terminal',
      },
      clickhandlers = {
        Lnum = function(args)
          if args.button ~= 'l' or fn.is_debug_mode() then
            require'statuscol.builtin'.lnum_click(args)
          end
        end,
      },
      ft_ignore = {
        'toggleterm',
      },
      relculright = true,
      segments = {
        { text = { ' ' } },
        {
          sign = { name = { 'Dap' } },
          condition = {
            function()
              return fn.is_debug_mode()
            end,
          },
          click = 'v:lua.ScLa',
        },
        {
          text = { require'statuscol.builtin'.lnumfunc },
          click = 'v:lua.ScLa',
        },
        {
          sign = { namespace = { 'gitsign' }, colwidth = 1 },
          click = 'v:lua.ScSa',
          hl = 'FoldColumn',
        },
        {
          text = { fn.foldfunc('󰐕', '┯', '┿', '│', '├', '└') },
          click = "v:lua.ScFa",
        },
        {
          text = { ' ' },
          hl = 'FoldColumn',
        },
        {
          sign = {
            name = { '.*' },
            maxwidth = 2,
            colwidth = 1,
            auto = true,
            wrap = true,
          },
          hl = 'FoldColumn',
        },
      },
    }
  end,
}
