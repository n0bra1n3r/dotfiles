return {
  config = function()
    require'mason'.setup {
      install_root_dir = vim.fn.expand("~/.local/share/nvim/mason"),
      ui = {
        border = "single",
      },
    }
  end,
}
