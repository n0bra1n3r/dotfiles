require"configs.packer".config()

require"packer".startup(function(packer_use)
  local use = fn.define_use(packer_use)

  -- Misc --

  use { "lewis6991/impatient.nvim" } -- must be loaded first
  use { "nvim-lua/plenary.nvim" }
  use { "nathom/filetype.nvim" }

  use { "wbthomason/packer.nvim", event = "VimEnter" }
  use { "kyazdani42/nvim-web-devicons", after = "packer.nvim" }
  use { "nvim-lualine/lualine.nvim", after = "nvim-web-devicons" }

  use { "folke/which-key.nvim", after = "packer.nvim" }

  -- Color Schemes --

  use { "EdenEast/nightfox.nvim" }

  -- File Types --

  use { "zah/nim.vim" }

  use { "kevinhwang91/nvim-bqf", ft = "qf" }

  -- Motions --

  use { "tpope/vim-repeat", event = "BufEnter" }
  use { "svermeulen/vim-easyclip", after = "vim-repeat" }
  use { "tpope/vim-unimpaired", event = "BufRead" }
  use { "tpope/vim-surround", event = "BufRead" }

  -- Projects --

  use { "ahmedkhalf/project.nvim", cond = fn.is_git_dir }
  use { "rmagatti/auto-session", after = "project.nvim" }

  -- Navigation --

  use { "ggandor/lightspeed.nvim", event = "BufRead" }

  use { "nvim-telescope/telescope.nvim", module = "telescope", cmd = "Telescope" }

  -- VCS --

  use { "lewis6991/gitsigns.nvim", cond = fn.is_git_dir }

  use { "sindrets/diffview.nvim", cond = fn.is_git_dir }

  -- LSP --

  use { "neovim/nvim-lspconfig",
    setup = function()
      fn.lazy_load"nvim-lspconfig"()
      fn.vim_defer[[if &ft == 'packer' | echo '' | else | silent! e %]]()
    end,
  }
  use { "j-hui/fidget.nvim", after = "nvim-lspconfig" }
  use { "ray-x/lsp_signature.nvim", after = "fidget.nvim" }

  use { "nvim-treesitter/nvim-treesitter", event = "BufRead" }

  use { "onsails/lspkind-nvim", event = "InsertEnter" }
  use { "hrsh7th/nvim-cmp", after = "lspkind-nvim" }
  use { "windwp/nvim-autopairs", after = "nvim-cmp" }
  use { "L3MON4D3/LuaSnip", after = "nvim-autopairs" }
  use { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" }
  use { "hrsh7th/cmp-nvim-lsp", after = "cmp_luasnip" }

  -- Editing --

  use { "numToStr/Comment.nvim", event = "BufRead" }

  use { "echasnovski/mini.nvim", event = "BufRead"}

  -- Command Runners --

  use { "skywind3000/asyncrun.vim", cmd = { "AsyncRun" } }

  use { "skywind3000/asynctasks.vim",
    cmd = { "AsyncTask", "AsyncTaskMacro", "AsyncTaskList", "AsyncTaskProfile", "AsyncTaskEdit" } }

  use { "voldikss/vim-floaterm",
    cmd = { "FloatermNew", "FloatermShow", "FloatermToggle" }, fn = { "floaterm#new" } }

  if vim.g.bootstrapped then
    require"packer".sync()
  end
end)
