require"configs.packer_nvim".config()

require"packer".startup(function(packer_use)
  local use = fn.define_use(packer_use)

  -- Misc --

  use { "wbthomason/packer.nvim", opt = true }

  use { "lewis6991/impatient.nvim" } -- must be loaded first
  use { "nvim-lua/plenary.nvim" }
  use { "nathom/filetype.nvim" }
  use { "kyazdani42/nvim-web-devicons" }
  use { "voldikss/vim-floaterm" }

  use { "nvim-lualine/lualine.nvim", after = "nvim-web-devicons" }

  use { "folke/which-key.nvim", event = "VimEnter" }

  -- Color Schemes --

  use { "EdenEast/nightfox.nvim" }

  -- File Types --

  use { "alaviss/nim.nvim", ft = "nim" }

  use { "kevinhwang91/nvim-bqf", ft = "qf" }
  use { "https://gitlab.com/yorickpeterse/nvim-pqf.git", as = "nvim-pqf" }

  -- Motions --

  use { "tpope/vim-repeat", event = "BufEnter" }
  use { "svermeulen/vim-cutlass", after = "vim-repeat" }
  use { "tpope/vim-unimpaired", event = "BufEnter" }
  use { "tpope/vim-surround", event = "BufEnter" }

  -- Projects --

  use { "ahmedkhalf/project.nvim", cond = fn.is_git_dir }
  use { "rmagatti/auto-session", after = "project.nvim"}

  -- Navigation --

  use { "echasnovski/mini.bufremove", event = "BufEnter"}

  use { "ggandor/lightspeed.nvim", event = "BufEnter" }

  use { "kevinhwang91/nvim-hlslens", event = "BufEnter" }
  use { "haya14busa/vim-asterisk", event = "BufEnter" }

  use { "nvim-telescope/telescope.nvim", module = "telescope", cmd = "Telescope" }

  use { "lewis6991/satellite.nvim", event = "VimEnter" }

  -- VCS --

  use { "lewis6991/gitsigns.nvim", cond = fn.is_git_dir }

  use { "sindrets/diffview.nvim", cond = fn.is_git_dir }

  -- LSP --

  use { "jose-elias-alvarez/null-ls.nvim", event = "BufRead" }
  use { "neovim/nvim-lspconfig", after = "null-ls.nvim" }

  use { "nvim-treesitter/nvim-treesitter", event = "BufRead" }

  use { "onsails/lspkind-nvim", event = "InsertEnter" }
  use { "hrsh7th/nvim-cmp", after = "lspkind-nvim" }
  use { "windwp/nvim-autopairs", after = "nvim-cmp" }
  use { "hrsh7th/cmp-nvim-lsp", after = "nvim-autopairs" }

  -- Editing --

  use { "numToStr/Comment.nvim", event = "BufRead" }
  use { "echasnovski/mini.cursorword", event = "BufRead" }
  use { "echasnovski/mini.trailspace", event = { "BufRead", "BufWritePre", "FileWritePre" } }

  use { "echasnovski/mini.indentscope", event = "BufRead" }
  use { "xiyaowong/virtcolumn.nvim", event = "BufRead" }

  -- Command Runners --

  use { "skywind3000/asyncrun.vim", cmd = { "AsyncRun" } }

  use { "skywind3000/asynctasks.vim",
    cmd = { "AsyncTask", "AsyncTaskMacro", "AsyncTaskList", "AsyncTaskProfile", "AsyncTaskEdit" } }

  if vim.g.bootstrapped then
    require"packer".sync()
  end
end)
