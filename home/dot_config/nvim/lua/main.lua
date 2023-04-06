-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Load Functions
_G.fn = {}

_G.fn.search = require "search"

require "functions"
--}}}

--{{{ Options
vim.g.mapleader = " "

vim.opt.background = "dark"
vim.opt.clipboard:append { "unnamed", "unnamedplus" }
vim.opt.cmdheight = 0
vim.opt.colorcolumn = "81,120"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.display:append "lastline"
vim.opt.display:append "uhex"
vim.opt.equalalways = true
vim.opt.expandtab = true
vim.opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
vim.opt.foldenable = false
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.guicursor = "v-n-sm:block,i-c-ci-ve:ver25,r-cr:hor20,o:hor20-blinkwait0-blinkon400-blinkoff250"
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.isfname = "@,48-57,/,\\,.,-,_,+,,,#,$,%,~,="
vim.opt.isident = "@,48-57,_,192-255"
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars:append "multispace:· "
vim.opt.listchars:append "tab:▸ "
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.ruler = false
vim.opt.scrollback = 9001
vim.opt.sessionoptions = "buffers,curdir,folds,winsize,winpos"
vim.opt.shiftwidth = 2
vim.opt.shortmess:append "sI"
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
vim.opt.whichwrap:append "<>[]hl"
vim.opt.wrap = true


local diagnostic_signs = {
  Error = "",
  Warn = "",
  Hint = "",
  Info = ""
}

for type, icon in pairs(diagnostic_signs) do
  local hl = "DiagnosticSign"..type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
--}}}

--{{{ Load Commands
_G.commands = function(commands)
  for command, def in pairs(commands) do
    local targetCmd = def[1]
    def[1] = nil

    vim.api.nvim_create_user_command(command, targetCmd, def)
  end
end

require "commands"
--}}}

--{{{ Load Mappings
_G.mappings = function(mappings)
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
end

require "mappings"
--}}}

--{{{ Load Plugins
local default_providers = {
  "node",
  "perl",
  "python3",
  "ruby",
}

for _, provider in ipairs(default_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

local lazypath = vim.fn.stdpath("data").."/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

local function get_plugin_config_name(plugin)
  return string.gsub(vim.fn.fnamemodify(plugin, ":t"), "%.", "_")
end

_G.plugins = function(plugins)
  for _, spec in pairs(plugins) do
    local plugin = spec[1]
    local config = get_plugin_config_name(plugin)

    local hasConfig, module = pcall(require, "configs."..config)
    if hasConfig then
      if module.init ~= nil then
        if spec.init == nil then
          spec.init = module.init
        else
          local spec_init = spec.init
          spec.init = function()
            spec_init()
            module.init()
          end
        end
      end
      if module.config ~= nil then
        if spec.config == nil then
          spec.config = function()
            module.config()
          end
        else
          local spec_config = spec.config
          spec.config = function()
            spec_config()
            module.config()
          end
        end
      end
    end
  end

  require'lazy'.setup(plugins, {
    defaults = {
      lazy = true,
    },
    install = {
      colorscheme = { "nordfox" },
    },
    ui = {
      border = "single",
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "2html_plugin",
          "bugreport",
          "compiler",
          "ftplugin",
          "getscript",
          "getscriptPlugin",
          "gzip",
          "logipat",
          "netrw",
          "netrwPlugin",
          "netrwSettings",
          "netrwFileHandlers",
          "matchit",
          "optwin",
          "rplugin",
          "rrhelper",
          "spellfile",
          "spellfile_plugin",
          "syntax",
          "synmenu",
          "tar",
          "tarPlugin",
          "tohtml",
          "tutor",
          "vimball",
          "vimballPlugin",
          "zip",
          "zipPlugin",
        },
      },
    },
  })
end

local function set_plugins_keymap(key, method)
  local config_folder = "~/.local/share/chezmoi/home/dot_config/nvim/lua/configs/"

  vim.api.nvim_buf_set_keymap(0, "n", key, [[]], {
    noremap = true,
    callback = function()
      local plugin = vim.fn.expand("<cfile>")
      local config = get_plugin_config_name(plugin)
      fn.edit_file(method, config_folder..config..".lua")
    end,
  })
end

vim.api.nvim_create_autocmd("BufEnter", {
  once = true,
  pattern = "*/nvim/lua/plugins.lua",
  callback = function()
    set_plugins_keymap("gf", "edit")
    set_plugins_keymap("<C-w><C-f>", "vsplit")
    set_plugins_keymap("<C-w>f", "split")
  end,
})

require "plugins"
--}}}
