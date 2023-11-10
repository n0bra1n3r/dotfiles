return {
  config = function()
    local notify_level = {
      [vim.log.levels.DEBUG] = 'DEBUG',
      [vim.log.levels.ERROR] = 'ERROR',
      [vim.log.levels.INFO] = 'INFO',
      [vim.log.levels.TRACE] = 'TRACE',
      [vim.log.levels.WARN] = 'WARN',
      [vim.log.levels.OFF] = 'OFF',
    }

    require'notify'.setup {
      icons = {
        DEBUG = '󰉄',
        ERROR = '',
        INFO = '',
        TRACE = '󰎈',
        WARN = ''
      },
      on_open = function(win, record)
        vim.api.nvim_create_autocmd('WinEnter', {
          buffer = vim.api.nvim_win_get_buf(win),
          callback = function()
            vim.api.nvim_win_close(win, true)
          end,
        })
      end,
      stages = {
        function(state)
          local next_height = state.message.height + 2
          local next_row = require'notify.stages.util'.available_slot(
            state.open_windows,
            next_height,
            require'notify.stages.util'.DIRECTION.TOP_DOWN
          )
          if not next_row then
            return nil
          end
          local is_tabline_visible = vim.o.showtabline ~= 0 and #vim.o.tabline ~= 0
          local row = next_row == 0
            and next_row + (is_tabline_visible and 2 or 1)
            or next_row
          return {
            anchor = 'NE',
            border = 'single',
            col = vim.o.columns,
            height = state.message.height,
            relative = 'editor',
            row = row,
            style = 'minimal',
            width = state.message.width,
          }
        end,
        function()
          return {
            col = { vim.o.columns },
            time = true,
          }
        end,
      },
    }

    _G.fallback_print = _G.print

    local is_notifying = false

    _G.vim.notify = function(msg, level, opts)
      if not opts then
        opts = {}
      end

      if not opts.title or #opts.title == 0 then
        if not msg or #msg == 0 then
          return
        end

        if not opts.replace then
          opts.title = "neovim"
        end
      end

      if is_notifying then
        fallback_print(('[%s] %s: %s'):format(opts.title, level, msg))
        return
      end

      is_notifying = true

      opts.animate = false

      local max_len = 50

      if opts.title and #opts.title > max_len then
        opts.title = opts.title:sub(1, 20)..'...'..opts.title:sub(-20, -1)
      end

      local lines

      if msg then
        lines = {}

        for _, line in ipairs(vim.split(msg, '\n')) do
          for j = 1, #line, max_len do
            table.insert(lines, line:sub(j, j + max_len - 1))
          end
        end
      end

      if not opts.replace then
        local job = require'plenary.job':new {
          args = { vim.fn.expand'~/.dotfiles/scripts/bell' },
          command = "sh",
          detached = true,
        }
        job:start()
      end

      local is_ok, res = pcall(require'notify', lines, notify_level[level], opts)

      is_notifying = false

      return is_ok and res
    end

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
