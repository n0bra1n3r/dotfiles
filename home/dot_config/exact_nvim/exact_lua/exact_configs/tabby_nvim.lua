function plug.config()
  require'tabby.tabline'.set(function(line)
    local tabs = {}

    for _, tag in ipairs(require'grapple'.tags()) do
      local key = tag.key
      local path = tag.file_path
      local cur_path = vim.api.nvim_buf_get_name(0)
      table.insert(tabs, {
        line.sep(' ', 'TabLine', 'TabLineFill'),
        path == cur_path and '󰃀' or '󰃃',
        key,
        vim.fn.pathshorten(vim.fn.fnamemodify(path, ':~:.')),
        line.sep(' ', 'TabLine', 'TabLineFill'),
        hl = 'TabLine',
        margin = ' ',
      })
    end
    return {
      line.spacer(),
      tabs,
      hl = 'TabLineFill',
    }
  end)

  if #require'grapple'.tags() > 0 then
    vim.o.showtabline = 2
  end
end
