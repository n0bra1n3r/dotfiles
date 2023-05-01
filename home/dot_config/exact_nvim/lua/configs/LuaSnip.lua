function plug.config()
  require'luasnip.loaders.from_vscode'.lazy_load()
  require'luasnip.loaders.from_vscode'.lazy_load {
    paths = {
      vim.env.MYVIMRC.."/snippets"
    },
  }
end
