return {
  config = function()
    require 'overseer'.setup {
      confirm = {
        border = "single",
      },
      form = {
        border = "single",
      },
      strategy = "jobstart",
      task_win = {
        border = "single",
      },
    }
  end,
}
