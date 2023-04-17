plugins {
  -- Misc --

  { "nvim-lua/plenary.nvim" },

  { "nathom/filetype.nvim", lazy = false },

  -- UI --

  { "kyazdani42/nvim-web-devicons" },

  { "catppuccin/nvim", name = "catppuccin.nvim", lazy = false },
  { "nvim-lualine/lualine.nvim", lazy = false },

  { "kevinhwang91/nvim-bqf", ft = "qf" },
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git", event = "VeryLazy" },

  -- Key Mappings --

  { "folke/which-key.nvim", event = "VeryLazy" },

  -- Terminal --

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

  -- Frameworks --

  { "alaviss/nim.nvim", ft = "nim" },
  { "akinsho/flutter-tools.nvim", ft = "dart" },

  -- Motions --

  { "tpope/vim-repeat", event = "BufModifiedSet" },
  { "tpope/vim-surround", event = { "BufRead", "BufModifiedSet" } },

  -- Navigation --

  { "echasnovski/mini.bufremove" },

  { "ggandor/leap.nvim", event = { "BufRead", "BufModifiedSet" }, dependencies = { "tpope/vim-repeat" } },

  { "kevinhwang91/nvim-hlslens", event = { "BufRead", "BufModifiedSet" } },
  { "haya14busa/vim-asterisk", event = { "BufRead", "BufModifiedSet" } },

  { "nvim-telescope/telescope.nvim", event = "VeryLazy" },

  -- VCS --

  { "lewis6991/gitsigns.nvim", event = "BufRead" },

  -- Completion --

  { "nvim-treesitter/nvim-treesitter" },
  { "onsails/lspkind-nvim" },

  { "neovim/nvim-lspconfig", event = "BufRead" },

  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
  { "hrsh7th/nvim-cmp", event = "InsertEnter" },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = "hrsh7th/nvim-cmp",
  },

  -- Editor --

  { "numToStr/Comment.nvim", event = { "BufRead", "BufModifiedSet" } },
  { "echasnovski/mini.cursorword", event = { "BufRead", "BufModifiedSet" } },
  {
    "echasnovski/mini.trailspace",
    event = {
      "BufRead",
      "BufModifiedSet",
      "BufWritePre",
      "FileWritePre",
    },
  },
  { "echasnovski/mini.indentscope", event = { "BufRead", "BufModifiedSet" } },
  { "xiyaowong/virtcolumn.nvim", event = "BufEnter" },

  -- Command Runners --

  { "skywind3000/asyncrun.vim", cmd = { "AsyncRun", "AsyncStop" } },

  { "skywind3000/asynctasks.vim",
    cmd = {
      "AsyncTask",
      "AsyncTaskMacro",
      "AsyncTaskList",
      "AsyncTaskProfile",
      "AsyncTaskEdit",
    },
    dependencies = { "skywind3000/asyncrun.vim" },
  },

  -- Debuggers --

  { "mfussenegger/nvim-dap" },
}
