local M = {}

function M.config()
  require"pqf".setup {
    signs = {
      error = 'E',
      warning = 'W',
      info = 'I',
      hint = 'H'
    },
    show_multiple_lines = true,
  }

  local group = vim.api.nvim_create_augroup("conf_pqf", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "qf",
    callback = function()
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "getline(v:lnum)[1:]!=' '&&index(['E','H','I','W'],getline(v:lnum+1)[0])==-1?1:'<1'"
      vim.wo.foldcolumn = "2"
      vim.wo.foldtext = "getline(v:foldstart)"
      vim.wo.foldenable = true

      vim.api.nvim_buf_set_keymap(0, "n", [[<Tab>]], [[foldclosed('.')!=-1?'zMzO[z':'zM']], { expr = true, noremap = true })
    end,
  })

end

return M
