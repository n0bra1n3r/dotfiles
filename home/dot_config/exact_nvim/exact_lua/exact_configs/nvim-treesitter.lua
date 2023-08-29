function plug.config()
  require 'nvim-treesitter.install'.prefer_git = true
  require 'nvim-treesitter.install'.compilers = { "clang", "gcc" }

  local configs = require'nvim-treesitter.parsers'.get_parser_configs()

  configs.nim = {
    install_info = {
      url = "~/.dotfiles/deps/tree-sitter-nim/.dotfiles",
      files = {
        "src/parser.c",
        "src/scanner.cc",
      },
    },
  }

  -- install nim treesitter queries
  vim.opt.rtp:append(vim.fn.expand(configs.nim.install_info.url))

  configs.norg = {
    install_info = {
      url = "~/.dotfiles/deps/tree-sitter-norg/.dotfiles",
      files = {
        "src/parser.c",
        "src/scanner.cc",
      },
    },
  }

  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "bash",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "nim",
      "python",
    },
    highlight = {
      enable = true,
    },
  }
end
