plugins {
  -- Misc --

  { "nvim-lua/plenary.nvim" },
  { "kevinhwang91/promise-async" },

  { "nathom/filetype.nvim", lazy = false },

  -- UI --

  { "kyazdani42/nvim-web-devicons" },

  { "catppuccin/nvim", name = "catppuccin.nvim", lazy = false },
  { "nvim-lualine/lualine.nvim", lazy = false },
  { "arkav/lualine-lsp-progress", event = "LspAttach" },

  { "kevinhwang91/nvim-bqf", ft = "qf" },
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git", event = "VeryLazy" },

  {
    "kevinhwang91/nvim-ufo",
    event = "BufRead",
    dependencies = { "kevinhwang91/promise-async" },
  },

  -- Key Mappings --

  { "folke/which-key.nvim", event = "VeryLazy" },

  { "anuvyklack/hydra.nvim", event = "VeryLazy" },

  -- Terminal --

  {
    "akinsho/toggleterm.nvim",
    cmd = {
      "ToggleTerm",
      "ToggleTermToggleAll",
      "TermExec",
      "ToggleTermSetName",
    },
  },

  -- Frameworks --

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

  -- Package Management --

  { "williamboman/mason.nvim", build = ":MasonUpdate" },

  -- Completion --

  { "williamboman/mason-lspconfig.nvim" },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    ft = {
      "nim",
      "nimble",
      "nims",
    },
  },

  { "L3MON4D3/LuaSnip" },

  { "VonHeikemen/lsp-zero.nvim" },

  { "hrsh7th/cmp-nvim-lsp-signature-help" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-path" },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
    },
  },

  { "hrsh7th/cmp-nvim-lsp" },

  {
    "neovim/nvim-lspconfig",
    cmd = "LspInfo",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
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

  { "https://git.sr.ht/~whynothugo/lsp_lines.nvim", event = "LspAttach" },

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

  { "theHamsta/nvim-dap-virtual-text" },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
    },
  },
}
