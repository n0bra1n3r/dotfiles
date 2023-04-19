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

  { "j-hui/fidget.nvim", event = "BufEnter" },

  -- Key Mappings --

  { "folke/which-key.nvim", event = "VeryLazy" },

  -- Terminal --

  {
    "akinsho/toggleterm.nvim",
    cmd = {
      "ToggleTerm",
      "ToggleTermToggleAll",
      "TermExec",
      "ToggleTermSetName"
    },
  },

  -- Frameworks --

  { "alaviss/nim.nvim", ft = "nim" },
  { "akinsho/flutter-tools.nvim", ft = "dart" },

  -- Motions --

  { "tpope/vim-repeat", event = "BufModifiedSet" },
  { "tpope/vim-surround", event = { "BufRead", "BufModifiedSet" } },

  -- Navigation --

  { "echasnovski/mini.bufremove" },

  {
    "ggandor/leap.nvim",
    keys = { "S", "s" },
    dependencies = { "tpope/vim-repeat" },
  },
  {
    "ggandor/flit.nvim",
    keys = { "F", "T", "f", "t" },
    dependencies = { "ggandor/leap.nvim" },
  },

  { "kevinhwang91/nvim-hlslens", event = { "BufRead", "BufModifiedSet" } },
  { "haya14busa/vim-asterisk", event = { "BufRead", "BufModifiedSet" } },

  { "nvim-telescope/telescope.nvim", event = "VeryLazy" },

  -- VCS --

  { "lewis6991/gitsigns.nvim", event = "BufRead" },

  -- Completion --

  { "nvim-treesitter/nvim-treesitter" },

  { "onsails/lspkind.nvim" },

  { "neovim/nvim-lspconfig" },

  { "hrsh7th/cmp-nvim-lsp-signature-help" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-path" },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
    },
  },

  { "hrsh7th/cmp-nvim-lsp" },

  { "L3MON4D3/LuaSnip" },

  {
    "VonHeikemen/lsp-zero.nvim",
    event = "BufEnter",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
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
