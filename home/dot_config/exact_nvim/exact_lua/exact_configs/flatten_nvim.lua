return {
  config = function()
    require'flatten'.setup {
      nest_if_no_args = true,
      window = {
        open = function(_, args, stdin_buf, cwd)
          local num_paths = 0
          for _, path in ipairs(vim.list_slice(args, 3)) do
            if vim.fn.isdirectory(path) == 1 then
              fn.open_workspace(path)
              num_paths = num_paths + 1
            elseif vim.fn.filereadable(path) == 1 then
              vim.cmd.tabnew(path)
              num_paths = num_paths + 1
            end
          end
          if num_paths == 0 then
            fn.open_workspace(cwd)
          end
          if stdin_buf then
            if fn.is_empty_buffer(stdin_buf.bufnr) then
              vim.api.nvim_buf_delete(stdin_buf.bufnr, { force = true })
            end
          end
          return vim.api.nvim_get_current_buf()
        end
      }
    }
  end
}
