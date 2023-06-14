-- vim: foldmethod=marker foldlevel=0 foldenable

_G.my_config = {}

function _G.get_my_config_json(key)
  return vim.fn.json_encode(my_config[key])
end

--{{{ Load Globals
_G.my_globals = function(globals)
  my_config.globals = vim.tbl_extend(
    "force",
    my_config.globals or {},
    vim.deepcopy(globals))
  for key, value in pairs(globals) do
    vim.g[key] = value
  end
end

require "globals"
--}}}
--{{{ Load Options
_G.my_options = function(options)
  my_config.options = vim.tbl_extend(
    "force",
    my_config.options or {},
    vim.deepcopy(options))
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
_G.my_signs = function(signs)
  my_config.signs = vim.tbl_extend(
    "force",
    my_config.signs or {},
    vim.deepcopy(signs))
  for name, opts in pairs(signs) do
    vim.fn.sign_define(name, opts)
  end
end

require "signs"
--}}}
--{{{ Load Functions
my_config.functions = {}
_G.fn = my_config.functions

require "functions"
--}}}
--{{{ Load Autocmds
_G.my_autocmds = function(autocmds)
  my_config.autocmds = vim.tbl_extend(
    "force",
    my_config.autocmds or {},
    vim.deepcopy(autocmds))
  local group = vim.api.nvim_create_augroup("main", { clear = true })
  for autocmd, def in pairs(autocmds) do
    if def[1] == nil then
      def.group = group
      vim.api.nvim_create_autocmd(autocmd, def)
    else
      for _, nested_def in ipairs(def) do
        nested_def.group = group
        vim.api.nvim_create_autocmd(autocmd, nested_def)
      end
    end
  end
end

require "autocmds"
--}}}
--{{{ Load Commands
_G.my_commands = function(commands)
  my_config.commands = vim.deepcopy(commands)
  for command, def in pairs(commands) do
    local info = def
    if type(info) == "string" then
      info = my_config.commands[def]
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

_G.my_plugins = function(plugins)
  my_config.plugins = vim.tbl_extend(
    "force",
    my_config.plugins or {},
    vim.deepcopy(plugins))
  for _, spec in ipairs(plugins) do
    local plugin = spec.name or spec[1]
    local config = get_plugin_config_name(plugin)
    local module = {}
    _G.plug = module
    local hasConfig, _ = pcall(require, "configs."..config)
    if hasConfig then
      if module.init ~= nil then
        if spec.init == nil then
          spec.init = module.init
        else
          local spec_init = spec.init
          spec.init = function(def)
            spec_init(def)
            module.init(def)
          end
        end
      end
      if module.config ~= nil then
        if spec.config == nil then
          spec.config = function(def)
            module.config(def)
          end
        else
          local spec_config = spec.config
          spec.config = function(def)
            spec_config(def)
            module.config(def)
          end
        end
      end
    end
    _G.plug = nil
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

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("conf_lazy", { clear = true }),
    pattern = "lazy",
    callback = function()
      vim.api.nvim_buf_set_keymap(0, "n", [[<Esc>]], [[<cmd>close<CR>]],
        { noremap = true, silent = true })
    end,
  })
end

local config_base = "~/.local/share/chezmoi/home/dot_config/exact_nvim/exact_lua/"
local config_dir = config_base.."exact_configs/"
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
--{{{ Load Highlights
_G.my_highlights = function(highlights)
  my_config.highlights = vim.tbl_extend(
    "force",
    my_config.highlights or {},
    vim.deepcopy(highlights))
  for name, value in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, value)
  end
end

require "highlights"
--}}}
--{{{ Load Mappings
_G.my_mappings = function(mappings)
  my_config.mappings = vim.tbl_extend(
    "force",
    my_config.mappings or {},
    vim.deepcopy(mappings))
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
--{{{ Load Launchers
_G.my_launchers = function(configs)
  my_config.launch = vim.tbl_extend(
    "force",
    my_config.launch or {},
    vim.deepcopy(configs))
end
--}}}
--{{{ Load Env
_G.my_env = function(env)
  my_config.env = vim.tbl_extend(
    "force",
    my_config.env or {},
    vim.deepcopy(env))
  for key, value in pairs(env) do
    vim.env[key] = value
  end
end
--}}}
--{{{ Load Snippets
_G.my_snippets = function(new_snippets)
  my_config.snippets = vim.tbl_extend(
    "force",
    my_config.snippets or {},
    vim.deepcopy(new_snippets))

  local nodePattern = [[%${(.-)}]]
  local nodeDelims = [[<>]]

  for language, snippets in pairs(my_config.snippets) do
    for name, snippet in pairs(snippets) do
      local nodes = {}
      for pattern in snippet.body:gmatch(nodePattern) do
        local parts = vim.split(pattern, ":")
        local index = tonumber(parts[1])
        local label = parts[2]
        if index ~= nil then
          table.insert(nodes, require'luasnip.nodes.insertNode'.I(index, label))
        end
      end
      local body = snippet.body:gsub(nodePattern, nodeDelims)
      local is_ok, snippet_entry = pcall(require'luasnip'.snippet,
        {
          dscr = snippet.description,
          name = name,
          trig = snippet.prefix,
        },
        require'luasnip.extras.fmt'.fmt(
          body,
          nodes,
          { delimiters = nodeDelims }
        )
      )

      if is_ok then
        require'luasnip'.add_snippets(
          language,
          { snippet_entry },
          { key = ("%s.%s"):format(language, name) }
        )
      else
        print(("Could not load snippet '%s' (%s)"):format(name, language))
      end
    end
  end
end

require "snippets"
--}}}
