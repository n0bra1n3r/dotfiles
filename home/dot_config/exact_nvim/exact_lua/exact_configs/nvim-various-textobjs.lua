return {
  config = function()
    require'various-textobjs'.setup{
      disabledKeymaps = {
        'gc',
      },
      useDefaultKeymaps = true,
    }
  end,
}
