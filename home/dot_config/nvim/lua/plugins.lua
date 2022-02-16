require"configs.packer".config()

require"packer".startup(function(packer_use)
  local use = fn.define_use(packer_use)

  -- Misc --

  use { "nvim-lua/plenary.nvim" }
  use { "lewis6991/impatient.nvim" }
  use { "nathom/filetype.nvim" }

  use { "wbthomason/packer.nvim", event = "VimEnter" }
  use { "kyazdani42/nvim-web-devicons", after = "packer.nvim" }
  use { "nvim-lualine/lualine.nvim", after = "nvim-web-devicons" }

  use { "folke/which-key.nvim", after = "packer.nvim" }

  -- Color Schemes --

  use { "EdenEast/nightfox.nvim" }

  -- Motions --

  use { "tpope/vim-repeat", event = "BufEnter" }
  use { "tpope/vim-surround", event = "BufEnter" }
  use { "tpope/vim-unimpaired", event = "BufEnter" }

  -- File Types --

  use { "zah/nim.vim" }

  -- LSP --

  use { "neovim/nvim-lspconfig",
    setup = function()
      fn.lazy_load"nvim-lspconfig"()
      fn.vim_defer[[if &ft == 'packer' | echo '' | else | silent! e %]]()
    end,
  }
  use { "ray-x/lsp_signature.nvim", after = "nvim-lspconfig" }

  use { "nvim-treesitter/nvim-treesitter", event = "BufRead" }

  use { "onsails/lspkind-nvim", event = "InsertEnter" }
  use { "hrsh7th/nvim-cmp", after = "lspkind-nvim" }
  use { "L3MON4D3/LuaSnip", after = "nvim-cmp" }
  use { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" }
  use { "hrsh7th/cmp-nvim-lsp", after = "cmp_luasnip" }
  use { "windwp/nvim-autopairs", after = "cmp-nvim-lsp" }

  -- Navigation --

  use { "nvim-telescope/telescope.nvim", module = "telescope", cmd = "Telescope",
    requires = {{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }} }

  use { "ggandor/lightspeed.nvim", event = "BufEnter" }

  use { "kyazdani42/nvim-tree.lua", after = "nvim-web-devicons" }

  -- VCS --

  use { "lewis6991/gitsigns.nvim", cond = fn.is_git_dir }

  use { "sindrets/diffview.nvim", cond = fn.is_git_dir }

  -- Command Runners --

  use { "skywind3000/asyncrun.vim", cmd = { "AsyncRun", "AsyncStop" } }

  use { "skywind3000/asynctasks.vim", cmd = { "AsyncTask", "AsyncTaskMacro", "AsyncTaskList", "AsyncTaskProfile", "AsyncTaskEdit" } }

  use { "voldikss/vim-floaterm", cond = fn.is_git_dir, cmd = { "FloatermNew", "FloatermShow", "FloatermToggle" }, fn = { "floaterm#new" } }

  -- Diagnostics --

  use { "kevinhwang91/nvim-bqf", ft = "qf" }

  -- Projects --

  use { "ahmedkhalf/project.nvim", cond = fn.is_git_dir }
  use { "rmagatti/auto-session", after = "project.nvim" }

  -- Editing --

  use { "numToStr/Comment.nvim", event = "BufRead" }

  use { "folke/todo-comments.nvim", event = "BufRead" }

  use { "echasnovski/mini.nvim", event = "BufRead"}

  use { "axelf4/vim-strip-trailing-whitespace", event = "CursorMoved" }
end)
