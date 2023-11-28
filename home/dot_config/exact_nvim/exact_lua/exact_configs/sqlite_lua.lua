return {
  init = function()
    local databases_dir = vim.fn.expand'~/.local/share/nvim/databases'

    if vim.fn.isdirectory(databases_dir) == 0 then
      vim.fn.mkdir(databases_dir, 'p')
    end

    if vim.fn.has('win32') == 1 then
      vim.g.sqlite_clib_path = vim.fn.expand'~/.dotfiles/deps/sqlite-dll/.local/bin/sqlite3.dll'
    else
      vim.g.sqlite_clib_path = vim.fn.expand'~/.dotfiles/deps/homebrew/.local/opt/sqlite/lib/libsqlite3.dylib'
    end
  end
}
