return {
  config = function()
    require'various-textobjs'.setup{
      keyMaps = {
        disabledDefaults = {
          'gc',
        },
        useDefaults = true,
      },
    }
  end,
}
