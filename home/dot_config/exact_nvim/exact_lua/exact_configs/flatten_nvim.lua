return {
  config = function()
    require'flatten'.setup {
      nest_if_no_args = true,
      window = {
        open = function(bufs, args, stdin_buf, cwd)
          if #bufs > 0 then
            for i, buf in ipairs(bufs) do
              local path = args[i + 2]
              if vim.fn.isdirectory(path) == 1 then
                fn.open_workspace(path)
              else
                vim.cmd.tabnew(path)
              end
              vim.api.nvim_buf_delete(buf.bufnr, { force = true })
            end
          else
            fn.open_workspace(cwd)
            vim.api.nvim_buf_delete(stdin_buf.bufnr, { force = true })
          end
          return vim.api.nvim_get_current_buf()
        end
      }
    }
  end
}
