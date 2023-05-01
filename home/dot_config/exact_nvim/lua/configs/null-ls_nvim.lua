local function nim_diagnostics()
  local ls = require'null-ls'
  local severities = require'null-ls.helpers'.diagnostics.severities
  return {
    method = ls.methods.DIAGNOSTICS,
    filetypes = { "nim" },
    generator = ls.generator {
      args = function(params)
        local file_name = vim.api.nvim_buf_get_name(params.bufnr)
        local cache_dir = vim.fn.fnameescape(fn.expand_path"~/nimcache/null-ls/")
          ..fn.url_encode(file_name)
        return {
          "compile",
          "--assertions:off",
          "--checks:off",
          "--debugInfo:off",
          "--define:test",
          "--errorMax:100",
          "--nimcache:"..cache_dir,
          "--noLinking:on",
          "--noMain:on",
          "--opt:none",
          "--stackTrace:off",
          "--stdout:on",
          "--eval:$TEXT",
        }
      end,
      command = "nim",
      format = "line",
      check_exit_code = function(code, stderr)
        if code > 1 then
          print(stderr)
        end
        return code <= 1
      end,
      on_output = function(line)
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
          row = row,
          col = column,
          code = code or type,
          severity = severity,
          message = message or "???",
        }
      end,
    },
  }
end

function plug.config()
  require'null-ls'.setup {
    sources = {
      nim_diagnostics(),
    },
  }
end