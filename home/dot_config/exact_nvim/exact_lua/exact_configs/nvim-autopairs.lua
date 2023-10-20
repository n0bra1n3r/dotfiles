return {
  config = function()
    require'nvim-autopairs'.setup {
      disable_filetype = { "TelescopePrompt" },
    }
    require'cmp'.event:on("confirm_done", require'nvim-autopairs.completion.cmp'.on_confirm_done())
  end,
}
