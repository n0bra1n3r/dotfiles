function plug.config()
  local dap = require'dap'

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      args = { "--port", "${port}" },
      command = "codelldb.cmd",
      detached = false,
    },
  }

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd().."/", "file")
      end,
    }
  }
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.nim = dap.configurations.cpp

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("conf_dap", { clear = true }),
    pattern = "dap-repl",
    callback = function()
      require'dap.ext.autocompl'.attach()
    end,
  })
end
