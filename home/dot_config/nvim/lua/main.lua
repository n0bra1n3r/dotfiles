require "functions"

_G.fn = vim.tbl_extend("keep", _G.fn, require "functions.init")

-- Options --

vim.g.mapleader = " "

vim.opt.background = "dark"
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
vim.opt.cmdheight = 1
vim.opt.colorcolumn = "81,120"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.display:append("lastline")
vim.opt.display:append("uhex")
vim.opt.equalalways = true
vim.opt.expandtab = true
vim.opt.fillchars = { eob = " " }
vim.opt.foldenable = false
vim.opt.foldmethod = "indent"
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.guicursor = "v-n-sm:block,i-c-ci-ve:ver25,r-cr:hor20,o:hor20-blinkwait0-blinkon400-blinkoff250"
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.isfname = "@,48-57,/,\\,.,-,_,+,,,#,$,%,~,="
vim.opt.isident = "@,48-57,_,192-255"
vim.opt.lazyredraw = true
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars:append("multispace:· ")
vim.opt.listchars:append("tab:▸ ")
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.ruler = false
vim.opt.scrollback = 9001
vim.opt.sessionoptions = "buffers,curdir,folds,options,winsize,winpos"
vim.opt.shiftwidth = 2
vim.opt.shortmess:append("sI")
vim.opt.showbreak = "↪"
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.showtabline = 0
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 3
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.spell = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 400
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.virtualedit = "onemore"
vim.opt.whichwrap:append("<>[]hl")
vim.opt.wrap = true

if os.getenv("MSYSTEM") ~= nil then
  vim.opt.shell = "cmd.exe"
end

-- Mappings --

local mappings = require "mappings"

for mode, mapping in pairs(mappings) do
  for key, map in pairs(mapping) do
    local targetKey = map[1]
    map[1] = nil

    if map.noremap == nil then
      map.noremap = true
    end
    if map.silent == nil then
      map.silent = true
    end

    if type(targetKey) == "function" then
      map = vim.tbl_extend("keep", map, { callback = targetKey })
      vim.api.nvim_set_keymap(mode, key, [[]], map)
    else
      vim.api.nvim_set_keymap(mode, key, targetKey, map)
    end
  end
end

-- Commands --

local commands = require "commands"

for command, def in pairs(commands) do
  local targetCmd = def[1]
  def[1] = nil

  vim.api.nvim_create_user_command(command, targetCmd, def)
end

-- Plugins --

local disabled_built_ins = {
   "2html_plugin",
   "getscript",
   "getscriptPlugin",
   "gzip",
   "logipat",
   "netrw",
   "netrwPlugin",
   "netrwSettings",
   "netrwFileHandlers",
   "matchit",
   "tar",
   "tarPlugin",
   "rrhelper",
   "spellfile_plugin",
   "vimball",
   "vimballPlugin",
   "zip",
   "zipPlugin",
}

for _, plugin in pairs(disabled_built_ins) do
   vim.g["loaded_"..plugin] = 1
end

local packer_path = vim.fn.stdpath("data").."/site/pack/packer/opt/packer.nvim"

if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
  print("Bootstrapping...")

  vim.fn.system {
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    "--depth",
    "1",
    packer_path,
  }

  vim.g.bootstrapped = true
end

vim.cmd[[packadd packer.nvim]]

require "plugins"
