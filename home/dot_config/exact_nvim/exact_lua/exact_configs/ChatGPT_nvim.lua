function plug.config()
  require'chatgpt'.setup {
    edit_with_instructions = {
      keymaps = {
        close = "<Esc>",
      },
    },
    chat = {
      keymaps = {
        close = { "<Esc>" },
      },
    },
  }
end

