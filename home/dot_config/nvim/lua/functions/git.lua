local M = {}

local is_git_dir = false
local git_branch = nil
local has_git_remote = false
local git_local_change_count = 0
local git_remote_change_count = 0

function M.refresh_git_change_info()
  if is_git_dir then
    git_local_change_count = tonumber(vim.fn.system(string.format("git rev-list --right-only --count %s@{upstream}...%s", git_branch, git_branch)))
    git_remote_change_count = tonumber(vim.fn.system(string.format("git rev-list --left-only --count %s@{upstream}...%s", git_branch, git_branch)))
  end
end

function M.refresh_git_info()
  vim.fn.system[[git rev-parse --is-inside-work-tree]]
  is_git_dir = vim.v.shell_error == 0

  if is_git_dir then
    git_branch = vim.fn.system[[git branch --show-current]]:match[[(.-)%s*$]]

    vim.fn.system("git show-branch remotes/origin/"..git_branch)
    has_git_remote = vim.v.shell_error == 0
  end

  fn.refresh_git_change_info()
end

function M.is_git_dir()
  return is_git_dir
end

function M.get_git_branch()
  return git_branch
end

function M.has_git_remote()
  return has_git_remote
end

function M.git_local_change_count()
  return git_local_change_count
end

function M.git_remote_change_count()
  return git_remote_change_count
end

return M
