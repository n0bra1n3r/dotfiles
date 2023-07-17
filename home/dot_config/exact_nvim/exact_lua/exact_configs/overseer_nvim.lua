function plug.config()
  require'overseer'.setup {
    confirm = {
      border = "single",
    },
    dap = false,
    form = {
      border = "single",
    },
    strategy = "jobstart",
    task_win = {
      border = "single",
    },
  }
end
