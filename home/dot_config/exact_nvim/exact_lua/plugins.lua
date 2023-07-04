my_plugins {
  -- Misc --

  { "nvim-lua/plenary.nvim" },
  { "kevinhwang91/promise-async" },
  { "echasnovski/mini.misc" },

  -- UI --

  { "kyazdani42/nvim-web-devicons" },

  { "catppuccin/nvim", name = "catppuccin.nvim", lazy = false },
  { "luukvbaal/statuscol.nvim", lazy = false },
  { "nvim-lualine/lualine.nvim", lazy = false },
  { "rcarriga/nvim-notify", lazy = false },
  { "stevearc/dressing.nvim", lazy = false },
  { "kevinhwang91/nvim-ufo", event = "BufRead",
    dependencies = { "kevinhwang91/promise-async" },
  },
  { "j-hui/fidget.nvim", event = "LspAttach" },

  { "kevinhwang91/nvim-bqf", ft = "qf" },
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git", event = "VeryLazy" },

  { "s1n7ax/nvim-window-picker", event = "WinEnter" },

  -- Key Mappings --

  { "folke/which-key.nvim", event = "VeryLazy" },

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

  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    ft = "norg",
    cmd = "Neorg",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
  },

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

  {
    "williamboman/mason.nvim",
    build = {
      ":MasonUpdate",
      ":MasonInstall codelldb",
      ":MasonInstall lua-language-server",
      ":MasonInstall bash-language-server",
      ":MasonInstall shellcheck",
      ":MasonInstall actionlint",
      ":MasonInstall dart-debug-adapter",
      ":MasonInstall robotframework-lsp",
    },
  },

  -- Completion --

  { "williamboman/mason-lspconfig.nvim" },

  {
    "nvim-treesitter/nvim-treesitter",
    build = {
      ":TSUpdate",
      ":TSInstall git_config",
      ":TSInstall git_rebase",
      ":TSInstall gitattributes",
      ":TSInstall gitcommit",
      ":TSInstall gitignore",
      ":TSInstall nim",
    },
    cmd = { "TSInstall", "TSInstallSync", "TSUninstall", "TSUpdate" },
    event = "BufRead",
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufRead",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },

  { "VonHeikemen/lsp-zero.nvim" },

  { "rafamadriz/friendly-snippets" },

  { "hrsh7th/cmp-nvim-lsp-signature-help" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-path" },
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
  },
  { "hrsh7th/cmp-nvim-lua" },
  { "folke/neodev.nvim" },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lua",
      "folke/neodev.nvim",
    },
  },

  { "hrsh7th/cmp-nvim-lsp" },

  {
    "neovim/nvim-lspconfig",
    cmd = "LspInfo",
    event = { "BufRead", "BufNewFile" },
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
  { "echasnovski/mini.splitjoin", event = { "BufRead" } },
  { "xiyaowong/virtcolumn.nvim", event = "VeryLazy" },

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
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },

  -- Configuration --

  { "klen/nvim-config-local", lazy = false },
}
