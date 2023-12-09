local function nim_get_project_file()
  local nimsuggest_project = vim.fn['nim#suggest#FindInstance']()
  if type(nimsuggest_project) == 'table'
      and type(nimsuggest_project.file) == 'string'
  then
    return nimsuggest_project.file
  end
end

local function nim_diagnostics(severities)
  local project_files = {}
  return {
    name = 'nim-diagnostics',
    method = require'null-ls'.methods.DIAGNOSTICS,
    filetypes = { 'nim' },
    generator = require'null-ls'.generator {
      args = function(params)
        if params.lsp_method == 'textDocument/didOpen' then
          local project_file = nim_get_project_file()
          if project_file then
            project_files[project_file] = true
            return {
              'check',
              '--stdout',
              project_file,
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
      runtime_condition = function(params)
        if params.lsp_method == 'textDocument/didOpen' then
          local project_file = nim_get_project_file()
          if project_file then
            return not project_files[project_file]
          end
        end
        return true
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
    m = itemKinds.Field,
  }

  return {
    name = 'nim-completion',
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

local function nim_hover()
  return {
    name = 'nim-hover',
    method = require'null-ls'.methods.HOVER,
    filetypes = { 'nim' },
    generator = {
      async = true,
      fn = function(_, done)
        local cur_win = vim.api.nvim_get_current_win()
        local cur_pos = vim.api.nvim_win_get_cursor(cur_win)
        vim.fn['nim#suggest#utils#Query'](
          'def',
          {
            on_data = function(reply)
              for _, item in ipairs(reply) do
                ---@diagnostic disable-next-line: param-type-mismatch
                local parts = vim.split(item, '\t', true)
                if parts[1] == 'def' then
                  local signature = parts[3]..': '..parts[4]
                  local docs = vim.split(vim.fn.eval(parts[8]), '\n')

                  table.insert(docs, 1, '-')
                  table.insert(docs, 1, signature)

                  done(docs)
                  return
                end
              end
              done{}
            end,
            pos = { cur_pos[1], cur_pos[2] + 1 },
          },
          false,
          true)
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
        nim_hover(),
      },
    }
  end,
}
