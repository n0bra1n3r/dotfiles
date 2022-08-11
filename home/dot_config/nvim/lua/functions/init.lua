local M = {}

function load_functions(name)
  local has_module, module = pcall(require, "functions."..name)
  if has_module then
    M = vim.tbl_extend("keep", M, module)
  end
end

load_functions "file"
load_functions "git"
load_functions "lsp"
load_functions "packerutils"
load_functions "vimutils"
load_functions "workspace"

return M
