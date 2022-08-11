local M = {}

function M.get_workspace_dir()
  local folder = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")

  if not fn.is_git_dir() then
    return folder
  end

  local branch = require"functions.git".get_git_branch()

  local branch_path = branch
  local folder_path = folder

  while true do
    local branch_part = vim.fn.fnamemodify(branch_path, ":t")
    local folder_part = vim.fn.fnamemodify(folder_path, ":t")

    if folder_part ~= branch_part then
      return folder
    end

    branch_path = vim.fn.fnamemodify(branch_path, ":h")
    folder_path = vim.fn.fnamemodify(folder_path, ":h")

    if branch_path == "." then
      return folder_path
    end
  end
end

function M.switch_workspace(path)
  vim.cmd[[FloatermKill!]]
  vim.cmd("Prosession "..path)
end

return M
