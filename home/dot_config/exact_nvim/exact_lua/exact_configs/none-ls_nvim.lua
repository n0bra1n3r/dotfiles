local function nim_diagnostics()
  local ls = require'null-ls'
  local severities = require'null-ls.helpers'.diagnostics.severities
  return {
    name = "nim",
    method = ls.methods.DIAGNOSTICS,
    filetypes = { "nim" },
    generator = ls.generator {
      args = function(params)
        local file_name = vim.api.nvim_buf_get_name(params.bufnr)
        local file_dir = vim.fn.fnamemodify(file_name, ":h")
        local cache_dir = "/null-ls/"..fn.url_encode(file_name)
        return {
          "compile",
          "--assertions:off",
          "--checks:off",
          "--define:diagnose",
          "--errorMax:100",
          "--nimcache:$nimcache/"..cache_dir,
          "--noMain:on",
          "--noLinking:on",
          "--opt:none",
          "--path:"..vim.fn.escape(file_dir, " "),
          "--stackTrace:off",
          "--stdout:on",
          "--eval:$TEXT",
        }
      end,
      check_exit_code = function(code)
        return code <= 1
      end,
      command = "nim",
      format = "line",
      on_output = function(line, params)
        local row, column, type, code, message =
          line:match[[%w+%.nims?%((%d+), ?(%d+)%):? (%w+) ?(%w*): (.+)$]]

        if row == nil or column == nil or type == nil or message == nil then
          return nil
        end

        if code ~= nil and #code == 0 then
          code = nil
        end

        if code == nil then
          local message1, code1 =
            message:match[[^(.+) %[(%w+)%]$]]

          if message1 ~= nil and code1 ~= nil then
            code = code1
            message = message1
          end
        end

        local severity = severities.information

        if type:lower() == "error" then
          severity = severities.error
        elseif type:lower() == "hint" then
          severity = severities.hint
        elseif vim.startswith(type:lower(), "warn") then
          severity = severities.warning
        end
        return {
          col = column,
          code = code or type,
          filename = vim.api.nvim_buf_get_name(params.bufnr),
          message = message or "???",
          row = row,
          severity = severity,
        }
      end,
    },
  }
end

return {
  config = function()
    require'null-ls'.setup {
      sources = {
        require'null-ls'.builtins.diagnostics.actionlint,
        --nim_diagnostics(),
      },
    }
  end,
}
