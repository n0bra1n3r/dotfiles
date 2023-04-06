plugins {
  -- Misc --

  { "nvim-lua/plenary.nvim" },
  { "kyazdani42/nvim-web-devicons" },

  { "nathom/filetype.nvim", lazy = false },

  { "catppuccin/nvim", name = "catppuccin.nvim", lazy = false },
  { "nvim-lualine/lualine.nvim", lazy = false },

  { "folke/which-key.nvim", event = "VeryLazy" },

  {
    "voldikss/vim-floaterm",
    init = function()
      vim.api.nvim_create_autocmd("FuncUndefined", {
        pattern = "floaterm*",
        once = true,
        command = [[Lazy load vim-floaterm]]
      })
    end
  },

  -- File Types --

  { "alaviss/nim.nvim", ft = "nim" },
  { "akinsho/flutter-tools.nvim", ft = "dart" },

  { "kevinhwang91/nvim-bqf", ft = "qf" },
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git", event = "VeryLazy" },

  -- Motions --

  { "tpope/vim-repeat", event = "BufModifiedSet" },
  { "svermeulen/vim-cutlass", event = { "BufRead", "BufModifiedSet" } },
  { "tpope/vim-unimpaired", event = { "BufRead", "BufModifiedSet" } },
  { "tpope/vim-surround", event = { "BufRead", "BufModifiedSet" } },

  -- Projects --

  { "rmagatti/auto-session", event = "VimEnter" },

  -- Navigation --

  { "echasnovski/mini.bufremove", event = "BufEnter" },

  { "ggandor/leap.nvim", event = { "BufRead", "BufModifiedSet" }, dependencies = { "tpope/vim-repeat" } },

  { "kevinhwang91/nvim-hlslens", event = { "BufRead", "BufModifiedSet" } },
  { "haya14busa/vim-asterisk", event = { "BufRead", "BufModifiedSet" } },

  { "nvim-telescope/telescope.nvim", event = "VeryLazy" },

  -- VCS --

  { "lewis6991/gitsigns.nvim", event = "BufRead" },

  { "sindrets/diffview.nvim", cmd = { "DiffViewFileHistory", "DiffViewOpen" } },

  -- LSP --

  { "nvim-treesitter/nvim-treesitter" },
  { "onsails/lspkind-nvim" },

  { "neovim/nvim-lspconfig", event = "BufRead" },

  { "jose-elias-alvarez/null-ls.nvim", event = "BufRead" },

  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
  { "hrsh7th/nvim-cmp", event = "InsertEnter" },

  { "windwp/nvim-autopairs", event = "InsertEnter" },

  -- Editing --

  { "numToStr/Comment.nvim", event = { "BufRead", "BufModifiedSet" } },
  { "echasnovski/mini.cursorword", event = { "BufRead", "BufModifiedSet" } },
  { "echasnovski/mini.trailspace", event = { "BufRead", "BufModifiedSet", "BufWritePre", "FileWritePre" } },

  { "echasnovski/mini.indentscope", event = { "BufRead", "BufModifiedSet" } },
  { "xiyaowong/virtcolumn.nvim", event = "BufEnter" },

  -- Command Runners --

  { "skywind3000/asyncrun.vim", cmd = { "AsyncRun", "AsyncStop" } },

  { "skywind3000/asynctasks.vim",
    cmd = { "AsyncTask", "AsyncTaskMacro", "AsyncTaskList", "AsyncTaskProfile", "AsyncTaskEdit" },
    dependencies = { "skywind3000/asyncrun.vim" },
  },

  -- Debuggers --

  { "mfussenegger/nvim-dap" },
}
