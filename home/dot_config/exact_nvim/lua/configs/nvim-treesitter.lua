function plug.config(plugin)
  local configs = require'nvim-treesitter.parsers'.get_parser_configs()

  configs.nim = {
    install_info = {
      url = "~/.dotfiles/tree-sitter-nim",
      files = {
        "src/parser.c",
        "src/scanner.cc",
      },
    },
  }

  local ts_nim_queries = plugin.dir.."/queries/nim"
  if vim.fn.isdirectory(ts_nim_queries) == 0 then
    local nvim_queries = vim.fn.expand"~/.dotfiles/tree-sitter-nim/queries/nvim"
    vim.fn.system(([[cp -rf '%s' '%s']]):format(nvim_queries, ts_nim_queries))
  end

  require'nvim-treesitter.configs'.setup {
    highlight = {
      enable = { "nim" },
    },
  }
end
