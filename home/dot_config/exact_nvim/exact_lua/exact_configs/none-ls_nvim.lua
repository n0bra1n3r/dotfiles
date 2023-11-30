local function nim_diagnostics(severities)
  return {
    name = 'nim',
    method = require'null-ls'.methods.DIAGNOSTICS,
    filetypes = { 'nim' },
    generator = require'null-ls'.generator {
      args = function(params)
        if params.lsp_method == 'textDocument/didOpen' then
          local nimsuggest_proj = vim.fn['nim#suggest#FindInstance']()
          if type(nimsuggest_proj) == 'table'
              and type(nimsuggest_proj.file) == 'string'
          then
            return {
              'check',
              '--stdout',
              nimsuggest_proj.file,
            }
          end
        end
        return {
          'check',
          '--errorMax:100',
          '--stdout',
          '--eval:$TEXT',
        }
      end,
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
          return done(nil)
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
            if filename == 'cmdfile.nim'
                or params.lsp_method == 'textDocument/didOpen'
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
        end

        return done(diagnostics)
      end,
    },
  }
end

local function nim_completion(itemKinds)
  local kinds = {
    d = itemKinds.Keyword,
    f = itemKinds.Function,
    t = itemKinds.Struct,
    v = itemKinds.Variable,
  }

  return {
    method = require'null-ls'.methods.COMPLETION,
    filetypes = { 'nim' },
    generator = {
      async = true,
      fn = function(_, done)
        vim.fn['nim#suggest#sug#GetAllCandidates'](function(_, candidates)
          local items = vim.tbl_map(function(candidate)
            return {
              kind = kinds[candidate.kind] or itemKinds.Text,
              label = candidate.word,
              detail = candidate.menu,
              documentation = candidate.info,
            }
          end, candidates)

          done{{ items = items }}
        end)
      end,
    },
  }
end

return {
  config = function()
    local severities = require'null-ls.helpers'.diagnostics.severities
    local itemKinds = vim.lsp.protocol.CompletionItemKind

    require'null-ls'.setup {
      log_level = 'off',
      sources = {
        require'null-ls'.builtins.formatting.swift_format,
        nim_completion(itemKinds),
        nim_diagnostics(severities),
      },
    }
  end,
}
