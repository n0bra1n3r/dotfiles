local M = {}

function M.lazy_load(plugin, timer)
  return function()
    require"functions.vimutils".vim_defer(function()
      require"packer".loader(plugin)
    end, timer)
  end
end

local function get_config(module)
  return "require'configs."..module.."'.config()"
end

local function get_setup(module)
  return "require'configs."..module.."'.setup()"
end

function M.define_use(packer_use)
  return function(opts)
    local plugin = opts[1]
    local config = string.gsub(vim.fn.fnamemodify(plugin, ":t"), "%.", "_")

    local hasConfig, module = pcall(require, "configs."..config)
    if hasConfig then
      if module.setup ~= nil and opts.setup == nil then
        opts.setup = get_setup(config)
      end
      if module.config ~= nil and opts.config == nil then
        opts.config = get_config(config)
      end
    end

    return packer_use(opts)
  end
end

return M
