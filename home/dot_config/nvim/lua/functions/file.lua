local M = {}

function M.delete_file()
  vim.fn.delete(vim.fn.expand('%:p'))
  vim.cmd[[Bdelete!]]
end

function M.open_file()
  local rel_dir = vim.fn.expand("%:h").."/"
  local path = vim.fn.input("open path: ", rel_dir, "dir")

  if #path == 0 or
      path == rel_dir or
      path.."/" == rel_dir then
    return
  end

  rel_dir = vim.fn.fnamemodify(path, ":h")
  if #vim.fn.glob(rel_dir) == 0 then
    vim.cmd(string.format("!bash -c 'mkdir -p \"%s\"'", rel_dir))
  end
  vim.cmd(string.format("edit %s", path))
end

function M.move_file()
  local rel_file = vim.fn.expand("%")
  local path = vim.fn.input("move path: ", rel_file, "file")

  if #path == 0 or
      path == rel_file then
    return
  end

  local rel_dir = vim.fn.fnamemodify(path, ":h")
  if #vim.fn.glob(rel_dir) == 0 then
    vim.cmd(string.format("!bash -c 'mkdir -p \"%s\"'", rel_dir))
  end
  vim.cmd(string.format("saveas %s | call delete(expand('#')) | bwipeout #", path))
end

function M.open_file_tree()
  if vim.fn["floaterm#terminal#get_bufnr"]("files") == -1 then
    local bufnr = vim.fn["floaterm#new"](0,
      "br",
      { [''] = '' },
      {
        silent = 1,
        name = "files",
        title = "files",
        height = math.ceil(vim.o.lines * 0.9),
        width = math.ceil(vim.o.columns * 0.9),
        position = "center",
      })
    vim.api.nvim_create_autocmd("TermLeave", {
      buffer = bufnr,
      command = "FloatermHide files",
    })
  end
  vim.cmd[[FloatermShow files]]
end

return M
