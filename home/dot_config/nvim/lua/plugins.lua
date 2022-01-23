require"configs.packer".config()

require"packer".startup(function(use)
  -- Misc --

  use { "nvim-lua/plenary.nvim" }

  use { "wbthomason/packer.nvim", event = "VimEnter" }
  use { "kyazdani42/nvim-web-devicons", after = "packer.nvim" }
  use { "nvim-lualine/lualine.nvim", after = "nvim-web-devicons",
    config = fn.get_config("lualine"),
  }
  use { "akinsho/bufferline.nvim", after = "lualine.nvim",
    config = fn.get_config("bufferline"),
  }
  use { "folke/which-key.nvim", after = "bufferline.nvim",
    config = fn.get_config("which-key"),
  }

  -- Color Schemes --

  use { "EdenEast/nightfox.nvim",
    config = fn.get_config("nightfox"),
  }

  -- File Types --

  use { "zah/nim.vim" }

  -- LSP --

  use { "neovim/nvim-lspconfig",
    setup = function()
      fn.lazy_load"nvim-lspconfig"()
      fn.vim_defer[[if &ft == 'packer' | echo '' | else | silent! e %]]()
    end,
    config = fn.get_config("lspconfig"),
  }
  use { "ray-x/lsp_signature.nvim", after = "nvim-lspconfig",
    config = fn.get_config("lsp_signature"),
  }

  use { "onsails/lspkind-nvim", event = "InsertEnter" }
  use { "hrsh7th/nvim-cmp", after = "lspkind-nvim",
    config = fn.get_config("cmp"),
  }
  use { "L3MON4D3/LuaSnip", after = "nvim-cmp" }
  use { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" }
  use { "hrsh7th/cmp-nvim-lsp", after = "cmp_luasnip" }

  use { "nvim-treesitter/nvim-treesitter", event = "BufRead" }

  -- Navigation --

  use { "nvim-telescope/telescope.nvim", module = "telescope", cmd = "Telescope",
    requires = { { "nvim-telescope/telescope-fzf-native.nvim", run = "make" } },
    config = fn.get_config("telescope"),
  }

  use { "ggandor/lightspeed.nvim", event = "BufEnter",
    requires = { "tpope/vim-repeat" },
  }

  use { "kyazdani42/nvim-tree.lua", cond = fn.is_git_dir,
    setup = fn.get_setup("nvim-tree"),
    config = fn.get_config("nvim-tree"),
  }

  use { "nacro90/numb.nvim", event = "BufEnter",
    config = fn.get_config("numb"),
  }

  use { "kevinhwang91/nvim-hlslens", event = "BufEnter",
    config = fn.get_config("hlslens"),
  }

  use { "eugen0329/vim-esearch", event = "BufEnter",
    setup = fn.get_setup("esearch"),
  }

  -- VCS --

  use { "lewis6991/gitsigns.nvim", cond = fn.is_git_dir,
    config = fn.get_config("gitsigns"),
  }

  use { "sindrets/diffview.nvim", cond = fn.is_git_dir,
    config = fn.get_config("diffview"),
  }

  -- Command Runners --

  use { "skywind3000/asyncrun.vim", cmd = "AsyncRun" }

  use { "voldikss/vim-floaterm", cmd = { "FloatermNew", "FloatermShow", "FloatermToggle" },
    setup = fn.get_setup("floaterm"),
    config = fn.get_config("floaterm"),
  }

  -- Diagnostics --

  use { "kevinhwang91/nvim-bqf", ft = "qf",
    config = fn.get_config("bqf"),
  }

  -- Projects --

  use { "ahmedkhalf/project.nvim", cond = fn.is_git_dir,
    config = fn.get_config("project_nvim"),
  }
  use { "rmagatti/auto-session", after = "project.nvim",
    config = fn.get_config("auto-session")
  }

  -- Editing --

  use { "numToStr/Comment.nvim", event = "BufRead",
    config = fn.get_config("Comment"),
  }

  use { "folke/todo-comments.nvim", event = "BufRead",
    config = fn.get_config("todo-comments"),
  }

  use { "axelf4/vim-strip-trailing-whitespace", event = "BufEnter" }
end)
