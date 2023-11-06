local function nim_diagnostics(severities)
  return {
    require'null-ls'.builtins.diagnostics.actionlint,
    {
      name = 'nim',
      method = require'null-ls'.methods.DIAGNOSTICS,
      filetypes = { 'nim' },
      generator = require'null-ls'.generator {
        args = {
          'check',
          '--errorMax:100',
          '--stdout',
          '--eval:$TEXT',
        },
        check_exit_code = function()
          return true
        end,
        cwd = function()
          return nil
        end,
        dynamic_command = function()
          return 'nim'
        end,
        format = 'raw',
        multiple_files = true,
        on_output = function(params, done)
          if not params.output then
            return done({})
          end

          local cur_filename = vim.api.nvim_buf_get_name(params.bufnr)

          local diagnostics = {}

          for line in vim.gsplit(
            params.output,
            '\n',
            {
              plain = true,
              trimempty = true,
            }
          )
          do
            local filename, row, column, type, message =
              line:match[[(.+)%((%d+), (%d+)%) (%a+): (.+)]]

            if filename ~= nil and
                row ~= nil and
                column ~= nil and
                type ~= nil and
                message ~= nil
            then
              if filename == 'cmdfile.nim' then
                filename = cur_filename
              end

              local severity = severities.information

              if type == 'Error' then
                severity = severities.error
              elseif type == 'Hint' then
                severity = severities.hint
              elseif type == 'Warning' then
                severity = severities.warning
              end

              local token = params.content[tonumber(row)]
                :sub(tonumber(column))
                :match('[%w_]+')

              table.insert(diagnostics, {
                col = column,
                end_col = column + (token and #token or 0),
                filename = filename,
                message = message,
                row = row,
                severity = severity,
                source = 'nim',
              })
            end
          end

          return done(diagnostics)
        end,
      },
    },
  }
end

return {
  config = function()
    local severities = require'null-ls.helpers'.diagnostics.severities
    require'null-ls'.setup {
      log_level = 'off',
      sources = nim_diagnostics(severities),
    }
  end,
}
