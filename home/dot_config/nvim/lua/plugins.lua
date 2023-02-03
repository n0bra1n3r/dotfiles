return {
  -- Misc --

  { "nvim-lua/plenary.nvim" },
  { "kyazdani42/nvim-web-devicons" },

  { "nathom/filetype.nvim", lazy = false },

  { "EdenEast/nightfox.nvim", lazy = false },
  { "nvim-lualine/lualine.nvim", lazy = false },

  { "folke/which-key.nvim", keys = "<leader>" },

  { "voldikss/vim-floaterm", event = "VeryLazy" },

  -- File Types --

  { "alaviss/nim.nvim", ft = "nim" },

  { "kevinhwang91/nvim-bqf", ft = "qf" },
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git", name = "nvim-pqf", ft = "qf" },

  -- Motions --

  { "tpope/vim-repeat", event = "BufModifiedSet" },
  { "svermeulen/vim-cutlass", event = { "BufRead", "BufModifiedSet" } },
  { "tpope/vim-unimpaired", event = { "BufRead", "BufModifiedSet" } },
  { "tpope/vim-surround", event = { "BufRead", "BufModifiedSet" } },

  -- Projects --

  --{ "ahmedkhalf/project.nvim", event = "VeryLazy", cond = fn.is_git_dir },
  --{ "rmagatti/auto-session", event = "VeryLazy", cond = fn.is_git_dir },

  -- Navigation --

  { "echasnovski/mini.bufremove", event = "BufEnter" },

  { "ggandor/lightspeed.nvim", event = { "BufRead", "BufModifiedSet" } },

  { "kevinhwang91/nvim-hlslens", event = { "BufRead", "BufModifiedSet" } },
  { "haya14busa/vim-asterisk", event = { "BufRead", "BufModifiedSet" } },

  { "nvim-telescope/telescope.nvim", cmd = "Telescope" },

  { "lewis6991/satellite.nvim", event = "BufEnter" },

  -- VCS --

  { "lewis6991/gitsigns.nvim", event = "BufRead", cond = fn.is_git_dir },

  { "sindrets/diffview.nvim", cmd = { "DiffViewFileHistory", "DiffViewOpen" }, cond = fn.is_git_dir },

  -- LSP --

  { "jose-elias-alvarez/null-ls.nvim", event = "BufRead" },
  { "neovim/nvim-lspconfig", event = "BufRead" },

  { "nvim-treesitter/nvim-treesitter", event = "BufRead" },

  { "onsails/lspkind-nvim", ft = "*", event = "InsertEnter" },
  { "hrsh7th/cmp-nvim-lsp", ft = "*", event = "InsertEnter" },
  { "hrsh7th/nvim-cmp", ft = "*", event = "InsertEnter" },

  { "windwp/nvim-autopairs", event = "BufModifiedSet" },

  -- Editing --

  { "numToStr/Comment.nvim", event = { "BufRead", "BufModifiedSet" } },
  { "echasnovski/mini.cursorword", event = { "BufRead", "BufModifiedSet" } },
  { "echasnovski/mini.trailspace", event = { "BufRead", "BufModifiedSet", "BufWritePre", "FileWritePre" } },

  { "echasnovski/mini.indentscope", event = { "BufRead", "BufModifiedSet" } },
  { "xiyaowong/virtcolumn.nvim", event = "BufEnter" },

  -- Command Runners --

  { "skywind3000/asyncrun.vim", cmd = "AsyncRun" },

  { "skywind3000/asynctasks.vim",
    cmd = { "AsyncTask", "AsyncTaskMacro", "AsyncTaskList", "AsyncTaskProfile", "AsyncTaskEdit" } },
}
