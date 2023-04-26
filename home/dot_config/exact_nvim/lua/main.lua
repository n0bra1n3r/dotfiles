-- vim: foldmethod=marker foldlevel=0 foldenable

config = {}

--{{{ Load Globals
globals = function(globals)
  config.globals = vim.deepcopy(globals)
  for key, value in pairs(globals) do
    vim.g[key] = value
  end
end

require "globals"
--}}}
--{{{ Load Options
options = function(options)
  config.options = vim.deepcopy(options)
  for option, value in pairs(options) do
    if type(option) == "string" then
      vim.opt[option] = value
    else
      vim.opt[value._name] = value
    end
  end
end

require "options"
--}}}
--{{{ Load Signs
signs = function(signs)
  config.signs = vim.deepcopy(signs)
  for name, value in pairs(signs) do
    for type, icon in pairs(value.icons) do
      local highlight = name..type
      vim.fn.sign_define(hl, {
        text = icon,
        texthl = highlight,
        numhl = highlight,
      })
    end
  end
end

require "signs"
--}}}
--{{{ Load Functions
config.functions = {}
fn = config.functions
fn.search = require "search"

require "functions"
--}}}
--{{{ Load Highlights
highlights = function(highlights)
  config.highlights = vim.deepcopy(highlights)
  for name, value in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, value)
  end
end

require "highlights"
--}}}
--{{{ Load Autocmds
autocmds = function(autocmds)
  config.autocmds = vim.deepcopy(autocmds)
  local group = vim.api.nvim_create_augroup("main", { clear = true })
  for autocmd, def in pairs(autocmds) do
    if def[1] == nil then
      def.group = group
      vim.api.nvim_create_autocmd(autocmd, def)
    else
      for _, def in ipairs(def) do
        def.group = group
        vim.api.nvim_create_autocmd(autocmd, def)
      end
    end
  end
end

require "autocmds"
--}}}
--{{{ Load Commands
commands = function(commands)
  config.commands = vim.deepcopy(commands)
  for command, def in pairs(commands) do
    local info = def
    if type(info) == "string" then
      info = config.commands[def]
    end
    local targetCmd = info[1]
    info[1] = nil
    vim.api.nvim_create_user_command(command, targetCmd, info)
  end
end

require "commands"
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

plugins = function(plugins)
  config.plugins = vim.deepcopy(plugins)
  for _, spec in ipairs(plugins) do
    local plugin = spec.name or spec[1]
    local config = get_plugin_config_name(plugin)
    local module = {}
    plug = module
    local hasConfig, _ = pcall(require, "configs."..config)
    if hasConfig then
      if module.init ~= nil then
        if spec.init == nil then
          spec.init = module.init
        else
          local spec_init = spec.init
          spec.init = function(plugin)
            spec_init(plugin)
            module.init(plugin)
          end
        end
      end
      if module.config ~= nil then
        if spec.config == nil then
          spec.config = function(plugin)
            module.config(plugin)
          end
        else
          local spec_config = spec.config
          spec.config = function(plugin)
            spec_config(plugin)
            module.config(plugin)
          end
        end
      end
    end
    plug = nil
  end

  require'lazy'.setup(plugins, {
    defaults = {
      lazy = true,
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
        reset = false,
      },
    },
  })
end

local config_base = "~/.local/share/chezmoi/home/dot_config/exact_nvim/lua/"
local config_dir = config_base.."configs/"
local function set_plugins_keymap(key, method)
  vim.api.nvim_buf_set_keymap(0, "n", key, [[]], {
    noremap = true,
    callback = function()
      local plugin = vim.fn.expand("<cfile>")
      local config = get_plugin_config_name(plugin)
      fn.edit_buffer(method, config_dir..config..".lua")
    end,
  })
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("plugins", { clear = true }),
  pattern = vim.fn.expand(config_base.."plugins.lua"),
  callback = function()
    set_plugins_keymap("gf", "edit")
    set_plugins_keymap("<C-w><C-f>", "vsplit")
    set_plugins_keymap("<C-w>f", "split")
    set_plugins_keymap("<C-w>gf", "tabe")
  end,
})

require "plugins"
--}}}
--{{{ Load Mappings
mappings = function(mappings)
  config.mappings = vim.deepcopy(mappings)
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
