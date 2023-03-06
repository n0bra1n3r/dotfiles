local M = {}

function M.config()
  require'pqf'.setup {
    show_multiple_lines = true,
  }

  local sign_keys = {
    "Error",
    "Warn",
    "Hint",
    "Info",
  }

  local signs = ""

  for _, sign_key in ipairs(sign_keys) do
    local sign_info = vim.fn.sign_getdefined("DiagnosticSign"..sign_key)
    if #sign_info > 0 then
      local sign = sign_info[1].text
      if sign ~= nil then
        signs = signs.."'"..string.sub(sign, 1, 1).."',"
      end
    end
  end

  local group = vim.api.nvim_create_augroup("conf_pqf", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "qf",
    callback = function()
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "getline(v:lnum)[1:]!=' '&&index(["..signs.."],getline(v:lnum+1)[0])==-1?1:'<1'"
      vim.wo.foldcolumn = "2"
      vim.wo.foldtext = "getline(v:foldstart)"
      vim.wo.foldenable = true

      vim.api.nvim_buf_set_keymap(0, "n", [[<Tab>]], [[foldclosed('.')!=-1?'zMzO[z':'zM']], { expr = true, noremap = true })
    end,
  })

end

return M
