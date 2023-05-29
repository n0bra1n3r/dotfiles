function plug.config()
  local dap = require'dap'

  dap.defaults.auto_continue_if_many_stopped = false

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      args = { "--port", "${port}" },
      command = "codelldb.cmd",
      detached = false,
    },
    options = {
      initialize_timeout_sec = 10,
    },
  }

  dap.configurations = setmetatable({}, {
    __index = function(_, filetype)
      local config = my_config.launch[filetype]
      if config == nil then
        config = {
          {
            name = "Launch file",
            type = "codelldb",
            require = "launch",
            program = function()
              return vim.fn.input("Path to file: ", vim.fn.getcwd().."/", "file")
            end,
          },
        }
      end
      for _, item in ipairs(config) do
        local env = item.env
        item.env = function()
          local env_table
          if type(env) == "function" then
            env_table = env()
          else
            env_table = env or {}
          end
          return vim.tbl_extend("keep", env_table, { PATH = vim.env.PATH })
        end
      end
      return config
    end,
  })
end
