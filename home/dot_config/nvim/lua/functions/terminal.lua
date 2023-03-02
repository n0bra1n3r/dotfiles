local M = {}

function M.open_terminal(command)
  if vim.fn["floaterm#terminal#get_bufnr"]("terminal") == -1 then
    vim.fn["floaterm#new"](0,
      "bash --rcfile ~/.dotfiles/floatermrc",
      { [''] = '' },
      {
        silent = 1,
        name = "terminal",
        title = " terminal [$1:$2]",
        borderchars = "",
        height = math.ceil(vim.o.lines * 0.3),
        width = math.ceil(vim.o.columns),
        position = "bottom",
      })
  end

  vim.cmd[[FloatermShow terminal]]

  if command ~= nil then
    vim.cmd(string.format('set ssl | exec "FloatermSend --name=terminal %s" | set nossl', command))
  end
end

return M
