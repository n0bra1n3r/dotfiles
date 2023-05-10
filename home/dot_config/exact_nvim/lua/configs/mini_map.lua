function plug.config()
  local group = vim.api.nvim_create_augroup("conf_mini_map", { clear = true })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      require'mini.map'.close()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "InsertLeave" }, {
    group = group,
    callback = function()
      if #vim.bo.buftype == 0 then
        require'mini.map'.open()
      end
    end,
  })

  require'mini.map'.setup {
    integrations = {
      require'mini.map'.gen_integration.builtin_search(),
      require'mini.map'.gen_integration.gitsigns(),
      require'mini.map'.gen_integration.diagnostic(),
    },
    symbols = {
      encode = require'mini.map'.gen_encode_symbols.dot("4x2"),
      scroll_line = '▶ ',
      scroll_view = '┃ ',
    },
    width = 8,
    window = {
      show_integration_count = false,
      winblend = 0,
    },
  }

  vim.api.nvim_set_hl(0, "MiniMapSymbolView", { link = "MiniMapSymbolLine" })
end
