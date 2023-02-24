return {
  -- Misc --

  { "nvim-lua/plenary.nvim" },
  { "kyazdani42/nvim-web-devicons" },

  { "nathom/filetype.nvim", lazy = false },

  { "EdenEast/nightfox.nvim", lazy = false },
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
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git", name = "nvim-pqf", ft = "qf" },

  -- Motions --

  { "tpope/vim-repeat", event = "BufModifiedSet" },
  { "svermeulen/vim-cutlass", event = { "BufRead", "BufModifiedSet" } },
  { "tpope/vim-unimpaired", event = { "BufRead", "BufModifiedSet" } },
  { "tpope/vim-surround", event = { "BufRead", "BufModifiedSet" } },

  -- Projects --

  { "ahmedkhalf/project.nvim", event = "VimEnter" },
  { "rmagatti/auto-session", event = "VimEnter" },

  -- Navigation --

  { "echasnovski/mini.bufremove", event = "BufEnter" },

  { "ggandor/lightspeed.nvim", event = { "BufRead", "BufModifiedSet" } },

  { "kevinhwang91/nvim-hlslens", event = { "BufRead", "BufModifiedSet" } },
  { "haya14busa/vim-asterisk", event = { "BufRead", "BufModifiedSet" } },

  { "nvim-telescope/telescope.nvim", event = "VeryLazy" },

  { "lewis6991/satellite.nvim", event = "BufEnter" },

  -- VCS --

  { "lewis6991/gitsigns.nvim", event = "BufRead" },

  { "sindrets/diffview.nvim", cmd = { "DiffViewFileHistory", "DiffViewOpen" } },

  -- LSP --

  { "nvim-treesitter/nvim-treesitter" },
  { "onsails/lspkind-nvim" },

  { "neovim/nvim-lspconfig", event = "BufRead" },

  { "jose-elias-alvarez/null-ls.nvim", event = "BufRead" },

  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
  { "hrsh7th/nvim-cmp", event = "InsertEnter", dependencies = { "tzachar/cmp-tabnine" } },
  { "tzachar/cmp-tabnine", build = "powershell ./install.ps1", cond = vim.fn.has("win32") },
  { "tzachar/cmp-tabnine", build = "./install.sh", cond = not vim.fn.has("win32") },

  { "windwp/nvim-autopairs", event = "InsertEnter" },

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

  -- Debuggers --

  { "mfussenegger/nvim-dap" },
}
