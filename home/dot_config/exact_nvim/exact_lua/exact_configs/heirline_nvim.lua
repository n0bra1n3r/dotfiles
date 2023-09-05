function plug.config()
  local function space(hl)
    return { provider = ' ', hl = hl }
  end

  local function align(hl)
    return { provider = '%=', hl = hl }
  end

  local function tab_label()
    return {
      {
        provider = '󰃀',
        hl = 'Comment',
      },
      space(),
      {
        provider = function(self)
          return self.key
        end,
        hl = 'Comment',
      },
      space(),
      {
        provider = function(self)
          return vim.fn.fnamemodify(self.path, ':~:.')
        end,
        hl = { italic = true },
        on_click = {
          callback = function(self)
            require'grapple'.select{ key = self.key }
            vim.schedule(vim.cmd.redrawtabline)
          end,
          name = function(self)
            return 'bookmark_select_callback'..self.key
          end,
        },
      },
    }
  end

  local function tab_close_btn()
    return {
      {
        provider = '',
        hl = 'Comment',
        on_click = {
          callback = function(self)
            require'grapple'.untag{ key = self.key }
            vim.schedule( vim.cmd.redrawtabline)
          end,
          name = function(self)
            return 'bookmark_untag_callback'..self.key
          end,
        },
      },
    }
  end

  local function tab()
    return {
      hl = 'TabLine',
      space'Normal',
      space(),
      tab_label(),
      space(),
      space(),
      tab_close_btn(),
      space(),
      space'Normal',
    }
  end

  local function tab_add_btn()
    return {
      hl = 'TabLine',
      space(),
      {
        provider = '󰃅',
        hl = 'Comment',
        on_click = {
          callback = function()
            local tags = require'grapple'.tags()
            vim.fn.sort(tags, function(a, b) return a.key - b.key end)
            local key
            for i, tag in ipairs(tags) do
              if i ~= tag.key then
                key = i
                break
              end
            end
            require'grapple'.tag{ key = key }
            vim.schedule(vim.cmd.redrawtabline)
          end,
          name = 'bookmark_tag_callback',
        },
      },
      space(),
    }
  end

  require'heirline'.setup {
    tabline = {
      hl = 'Normal',
      align(),
      {
        init = function(self)
          local tags = require'grapple'.tags()
          for i, tag in ipairs(tags) do
            local child = self[i]
            if not child or child.path ~= tag.file_path or child.key ~= tag.key
            then
              self[i] = self:new(tab(), i)
              child = self[i]
              child.key = tag.key
              child.path = tag.file_path
            end
          end
          if #self > #tags then
            for i = #tags + 1, #self do
              self[i] = nil
            end
          end
          vim.o.showtabline = #tags > 0 and 2 or 0
        end,
      },
      tab_add_btn(),
    },
  }
end
