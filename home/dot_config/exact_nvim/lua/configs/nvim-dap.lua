function plug.config()
  local dap = require'dap'

  dap.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = "OpenDebugAD7.cmd",
    options = {
      detached = false,
    },
  }

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "cppdbg",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd().."/", "file")
      end,
      cwd = "${workspaceFolder}",
    }
  }
  dap.configurations.nim = dap.configurations.cpp

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("conf_dap", { clear = true }),
    pattern = "dap-repl",
    callback = function()
      require'dap.ext.autocompl'.attach()
    end,
  })
end
