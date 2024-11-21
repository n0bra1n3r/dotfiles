return {
  config = function()
    require'codecompanion'.setup {
      strategies = {
        chat = {
          adapter = 'anthropic',
        },
        inline = {
          adapter = 'anthropic',
        },
      },
    }
  end,
}
