return {
  config = function()
    require'plenary.filetype'.add_table {
      extension = {
        ["nim"] = "nim",
        ["nims"] = "nims",
        ["nimble"] = "nimble",
      },
    }
  end,
}
