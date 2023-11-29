return {
  config = function()
    require'fidget'.setup {
      notification = {
        override_vim_notify = true,
        window = {
          y_padding = 1,
        },
      },
      progress = {
        display = {
          done_icon = '',
        },
      },
    }

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
