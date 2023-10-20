return {
  config = function()
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
  end,
}
