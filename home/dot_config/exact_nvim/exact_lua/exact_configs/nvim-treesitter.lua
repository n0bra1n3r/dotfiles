function plug.config(plugin)
  require 'nvim-treesitter.install'.prefer_git = true
  require 'nvim-treesitter.install'.compilers = { "clang", "gcc" }

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

  -- install nim treesitter queries
  local nim_queries = plugin.dir.."/queries/nim"
  if vim.fn.isdirectory(nim_queries) == 0 then
    local queries = vim.fn.expand"~/.dotfiles/tree-sitter-nim/queries/nvim"
    vim.fn.system(([[cp -rf '%s' '%s']]):format(queries, nim_queries))
  end

  configs.norg = {
    install_info = {
      url = "~/.dotfiles/tree-sitter-norg",
      files = {
        "src/parser.c",
        "src/scanner.cc",
      },
    },
  }

  require'nvim-treesitter.configs'.setup {
    highlight = {
      enable = true,
    },
  }
end
