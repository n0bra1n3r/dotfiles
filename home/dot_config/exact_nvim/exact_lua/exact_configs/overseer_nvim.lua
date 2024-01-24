return {
  config = function()
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

    require'dap.ext.vscode'.json_decode = require'overseer.json'.decode
  end,
}
