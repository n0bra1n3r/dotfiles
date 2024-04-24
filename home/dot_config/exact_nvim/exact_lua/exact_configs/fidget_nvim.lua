return {
  config = function()
    require'fidget'.setup {
      notification = {
        window = {
          winblend = 30,
          y_padding = 1,
        },
      },
      progress = {
        display = {
          done_icon = '',
        },
      },
    }

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg, level, opts)
      local line_limit = 4
      local char_limit = 50

      local lines = vim.split(msg, '\n',
        { plain = true, trimempty = true })

      if #lines > line_limit then
        local head = vim.list_slice(lines, 1, (line_limit + 1) / 2)
        table.insert(head, '...')
        lines = vim.list_extend(head,
          vim.list_slice(lines, #lines - line_limit / 2, #lines))
      end

      for i, line in ipairs(lines) do
        if #line > char_limit then
          lines[i] = line:sub(1, (char_limit + 1) / 2 - 2)
            ..'...'..line:sub(#lines - char_limit / 2 + 1, #line)
        end
      end

      require'fidget'.notify(vim.fn.join(lines, '\n'), level, opts)
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    _G.print = function(...)
      local args = { ... }

      local print_safe_args = {}
      for i = 1, #args do
        table.insert(print_safe_args, tostring(args[i]))
      end

      local message = table.concat(print_safe_args, ' ')
      local title
      while #message > 0 do
        local tag = message:match('^(%b[])')
        if not tag or #tag == 0 then
          break
        end
        if not title then
          title = tag:sub(2, -2)
        else
          title = title..' '..tag
        end
        message = vim.trim(message:sub(#tag + 1))
      end

      vim.notify(
        #message > 0 and message or 'nil',
        vim.log.levels.INFO,
        { title = title }
      )
    end
  end,
}
