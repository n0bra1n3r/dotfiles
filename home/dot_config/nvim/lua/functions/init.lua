local M = {}

function load_functions(name)
  local has_module, module = pcall(require, "functions."..name)
  if has_module then
    M = vim.tbl_extend("keep", M, module)
  else
    print("functions in "..name.." not loaded")
  end
end

local functions_path = "~/.config/nvim/lua/functions/*.lua"

for _, path in pairs(vim.fn.glob(functions_path, 0, 1)) do
  local module = vim.fn.fnamemodify(path, ":t:r")

  if module ~= "init" then
    load_functions(module)
  end
end

return M
