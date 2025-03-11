return {
  config = function()
    require'flatten'.setup {
      nest_if_no_args = true,
      window = {
        open = function(args)
          local num_paths = 0
          for _, file in ipairs(args.files) do
            if vim.fn.isdirectory(file.fname) == 1 then
              fn.open_workspace(file.fname)
              num_paths = num_paths + 1
            elseif vim.fn.filereadable(file.fname) == 1 then
              vim.cmd.tabnew(file.fname)
              num_paths = num_paths + 1
            end
          end
          if num_paths == 0 then
            fn.open_workspace(args.guest_cwd)
          end
          if args.stdin_buf then
            if fn.is_empty_buffer(args.stdin_buf.bufnr) then
              vim.api.nvim_buf_delete(args.stdin_buf.bufnr, { force = true })
            end
          end
          return vim.api.nvim_get_current_buf()
        end
      }
    }
  end
}
