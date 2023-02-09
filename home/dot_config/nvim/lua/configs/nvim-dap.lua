local M = {}

function M.config()
  require'dap'.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = vim.fn.expand"~/.dotfiles/deps/vscode-cpptools/extension/debugAdapters/bin/OpenDebugAD7",
    options = {
      detached = false,
    },
  }

  require'dap'.configurations.cpp = {
    {
      name = "Launch file",
      type = "cppdbg",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd().."/", "file")
      end,
      cwd = '${workspaceFolder}',
      stopAtEntry = true,
    },
  }

  require'dap'.configurations.nim = require'dap'.configurations.cpp
end

return M
