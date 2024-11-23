return {
  config = function()
    require'codecompanion'.setup {
      display = {
        chat = {
          render_headers = false,
        }
      },
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
