my_lsp_handlers {
  { "window/showMessage", --{{{
    callback = function(_, result, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local lvl = ({
        'ERROR',
        'WARN',
        'INFO',
        'DEBUG',
      })[result.type]
      vim.notify(result.message, lvl, {
        title = 'LSP | ' .. client.name,
        keep = function()
          return lvl == 'ERROR' or lvl == 'WARN'
        end,
      })
    end,
  } --}}}
}
