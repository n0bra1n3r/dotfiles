return {
  config = function()
    vim.api.nvim_create_autocmd("ModeChanged", {
      group = vim.api.nvim_create_augroup("conf_luasnip", { clear = true }),
      callback = function()
        local cur_buf = vim.api.nvim_get_current_buf()
        local event = vim.v.event
        if ((event.old_mode == "s" and event.new_mode == "n")
              or event.old_mode == "i")
            and require'luasnip'.session.current_nodes[cur_buf]
            and not require'luasnip'.session.jump_active then
          require'luasnip'.unlink_current()
        end
      end
    })
  end,
}
