return {
  config = function()
    local dap = require'dap'

    dap.defaults.auto_continue_if_many_stopped = false
    dap.defaults.fallback.exception_breakpoints = { 'uncaught' }
    dap.defaults.fallback.switchbuf = 'useopen,uselast'

    local codelldb_command
    if vim.fn.has('win32') == 1 then
      codelldb_command = 'codelldb.cmd'
    else
      codelldb_command = 'codelldb'
    end

    local codelldb = {
      executable = {
        args = { '--port', '${port}' },
        command = codelldb_command,
        detached = false,
      },
      options = {
        initialize_timeout_sec = 10,
      },
      port = '${port}',
      type = 'server',
    }

    dap.adapters = setmetatable({ codelldb = codelldb }, {
      __index = function(_, adapter)
        return my_config.debuggers and my_config.debuggers[adapter]
      end,
    })

    dap.configurations = setmetatable({}, {
      __index = function(_, filetype)
        local project_filetype =
          vim.g.project_filetypes[vim.g.project_type] or
          vim.g.project_type

        local config =
          my_config.launchers and (
            my_config.launchers[project_filetype] or
            my_config.launchers[filetype]
          ) or rawget(dap.configurations, project_filetype)

        if config == nil then
          config = {
            {
              name = "Launch file",
              program = fn.ui_input {
                completion = 'file',
                default = fn.get_tab_cwd()..'/',
                prompt = " 󰈔 Path to file: ",
              },
              request = 'launch',
              reverseDebugging = true,
              terminal = 'console',
              type = 'codelldb',
            },
          }
        end
        for _, item in ipairs(config) do
          local env = item.env
          item.env = function()
            local env_table
            if type(env) == 'function' then
              env_table = env()
            else
              env_table = env or {}
            end
            return vim.tbl_extend('keep', env_table, { PATH = vim.env.PATH })
          end
        end
        return config
      end,
    })

    -- load extensions
    require'nvim-dap-virtual-text'
  end,
}
