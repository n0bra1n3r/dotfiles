return {
  config = function()
    require'Comment'.setup()
    require'Comment.ft'.nim = { "#%s", "#[%s]#" }
  end,
}
