my_lsp_handlers {
  ['window/showMessage'] = { --{{{
    callback = function(_, result, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local log_level = ({
        vim.log.levels.ERROR,
        vim.log.levels.WARN,
        vim.log.levels.INFO,
        vim.log.levels.DEBUG,
      })[result.type]

      vim.notify(result.message, log_level, {
        title = 'LSP | '..client.name,
      })
    end,
  }, --}}}
}
