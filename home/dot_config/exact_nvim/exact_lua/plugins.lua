my_plugins {
  -- Misc --

  { "nvim-lua/plenary.nvim" },
  { "kevinhwang91/promise-async" },
  { "echasnovski/mini.misc" },

  -- UI --

  { "kyazdani42/nvim-web-devicons" },

  { "catppuccin/nvim", name = "catppuccin.nvim", lazy = false, priority = 1000 },
  { "luukvbaal/statuscol.nvim", lazy = false },
  { "rebelot/heirline.nvim", lazy = false },
  { "rcarriga/nvim-notify", lazy = false },
  { "stevearc/dressing.nvim", lazy = false },
  { "kevinhwang91/nvim-ufo", event = "BufRead",
    dependencies = { "kevinhwang91/promise-async" },
  },

  { "kevinhwang91/nvim-bqf", ft = "qf" },
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git", event = "VeryLazy" },

  { "MunifTanjim/nui.nvim" },

  { 'j-hui/fidget.nvim', tag = 'legacy', event = 'LspAttach' },

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

  { "akinsho/flutter-tools.nvim", lazy = false },

  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    ft = "norg",
    cmd = "Neorg",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- Motions --

  { "tpope/vim-repeat", event = "BufModifiedSet" },
  { "tpope/vim-surround", event = { "BufRead", "BufModifiedSet" } },
  { 'chrisgrieser/nvim-spider', event = { 'BufRead', 'BufModifiedSet' } },
  { 'chrisgrieser/nvim-various-textobjs', event = { 'BufRead', 'BufModifiedSet' } },
  { 'andymass/vim-matchup', lazy = false },

  -- Navigation --

  { "echasnovski/mini.bufremove" },

  { 'folke/flash.nvim', event = 'VeryLazy' },

  { "haya14busa/vim-asterisk", event = { "BufRead", "BufModifiedSet" } },

  { "nvim-telescope/telescope.nvim", event = "VeryLazy" },
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  { "s1n7ax/nvim-window-picker", event = "WinEnter" },

  { "cbochs/portal.nvim", event = "VeryLazy" },

  { "cbochs/grapple.nvim" },

  -- VCS --

  { "lewis6991/gitsigns.nvim", event = "BufRead" },
  { 'akinsho/git-conflict.nvim', event = 'VeryLazy' },

  -- Package Management --

  {
    'williamboman/mason.nvim',
    build = {
      ':MasonUpdate',
      ':MasonInstall actionlint',
      ':MasonInstall codelldb',
      ':MasonInstall dart-debug-adapter',
      ':MasonInstall graphql-language-service-cli',
      ':MasonInstall json-lsp',
      ':MasonInstall shellcheck',
    },
  },

  -- Syntax Highlighting --

  {
    "nvim-treesitter/nvim-treesitter",
    build = { ":TSUpdate" },
    cmd = { "TSInstall", "TSInstallSync", "TSUninstall", "TSUpdate" },
    event = "BufRead",
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'BufRead',
  },
  {
    'nvim-treesitter/nvim-treesitter-refactor',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'BufRead',
  },

  -- Language Servers --

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },

  { 'nvimtools/none-ls.nvim', event = 'BufRead' },
  { 'alaviss/nim.nvim', ft = 'nim' },

  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },

  { "VonHeikemen/lsp-zero.nvim" },

  { "hrsh7th/cmp-nvim-lsp-signature-help" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-path" },
  { "saadparwaiz1/cmp_luasnip", dependencies = { "L3MON4D3/LuaSnip" } },
  { "hrsh7th/cmp-nvim-lua" },
  { "folke/neodev.nvim" },
  { "folke/neoconf.nvim", lazy = false },
  {
    "hrsh7th/nvim-cmp",
    event = { 'InsertEnter', 'CmdlineEnter' },
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
      "folke/neoconf.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
  },

  { 'Robitx/gp.nvim', event = { 'BufRead' } },

  -- Editor --

  { "numToStr/Comment.nvim", event = { "BufRead", "BufModifiedSet" } },
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

  -- Command Runners --

  { "stevearc/overseer.nvim" },

  -- Debuggers --

  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },

  -- Configuration --

  { "klen/nvim-config-local", lazy = false },
}
