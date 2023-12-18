local M = {
  info = {
    diag_stack = {},
    proj_cache = {},
  },
  methods = {},
}

local function get_completion_item_kind(symbol_kind)
  return ({
    skConditional = vim.lsp.protocol.CompletionItemKind.Operator,
    skParam = vim.lsp.protocol.CompletionItemKind.Variable,
    skGenericParam = vim.lsp.protocol.CompletionItemKind.TypeParameter,
    skModule = vim.lsp.protocol.CompletionItemKind.Module,
    skType = vim.lsp.protocol.CompletionItemKind.Class,
    skVar = vim.lsp.protocol.CompletionItemKind.Variable,
    skLet = vim.lsp.protocol.CompletionItemKind.Value,
    skConst = vim.lsp.protocol.CompletionItemKind.Constant,
    skResult = vim.lsp.protocol.CompletionItemKind.Keyword,
    skProc = vim.lsp.protocol.CompletionItemKind.Function,
    skFunc = vim.lsp.protocol.CompletionItemKind.Function,
    skMethod = vim.lsp.protocol.CompletionItemKind.Method,
    skIterator = vim.lsp.protocol.CompletionItemKind.Method,
    skConverter = vim.lsp.protocol.CompletionItemKind.Method,
    skMacro = vim.lsp.protocol.CompletionItemKind.Function,
    skTemplate = vim.lsp.protocol.CompletionItemKind.Function,
    skField = vim.lsp.protocol.CompletionItemKind.Field,
    skEnumField = vim.lsp.protocol.CompletionItemKind.EnumMember,
    skForVar = vim.lsp.protocol.CompletionItemKind.Keyword,
    skLabel = vim.lsp.protocol.CompletionItemKind.Value,
  })[symbol_kind] or vim.lsp.protocol.CompletionItemKind.Text
end

local function get_or_open_buf(name)
  if not name then return 0 end
  local buf = vim.fn.bufnr(name)
  if buf == -1 then
    buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_call(buf, function()
      vim.cmd.edit(name)
    end)
  end
  return buf
end

local function get_word_at(buf, line, col)
  local line_text = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
  if line_text then
    local prefix = line_text:sub(1, col):match('[%w_]+$')
    local suffix = line_text:sub(col + 1):match('^[%w_]+')
    if not prefix then return suffix, col end
    return prefix..(suffix or ''), col - #prefix
  end
end

local function apply_diagnostics(ns, diagnostics)
  local bufs = {}
  for _, diagnostic in ipairs(diagnostics) do
    local buf = diagnostic.bufnr or vim.fn.bufnr(diagnostic.filename)
    if buf ~= -1 then
      local buf_diagnostics = bufs[buf]
      if not buf_diagnostics then
        buf_diagnostics = {}
        bufs[buf] = buf_diagnostics
      end
      if not diagnostic.end_col then
        local word = get_word_at(buf, diagnostic.lnum + 1, diagnostic.col)
        if word then
          diagnostic.end_col = diagnostic.col + #word
        end
      end
      table.insert(buf_diagnostics, diagnostic)
    end
  end
  for buf, buf_diagnostics in pairs(bufs) do
    vim.diagnostic.set(ns, buf, buf_diagnostics)
  end
end

local function name_to_severity(name)
  local severities = vim.diagnostic.severity
  if name == 'Error' then
    return severities.ERROR
  elseif name == 'Hint' then
    return severities.HINT
  elseif name == 'Warning' then
    return severities.WARN
  end
  return severities.INFO
end

local function path_to_uri(path)
  if vim.fn.has('win32') == 1 then
    return 'file:///'..path
  else
    return 'file://'..path
  end
end

local function prettify_param_string(string)
  local prefix = string:match('^([%w_]+)') or ''
  local params = string:match('%((.*)') or ''
  local params_parts = vim.split(params, ',')
  if #params_parts <= 1 then
    return prefix..'('..params
  end
  local result = prefix..'(\n '
  result = result..vim.fn.join(params_parts, ',\n')
  return result
end

local function uri_to_path(uri)
  if vim.fn.has('win32') == 1 then
    return uri:match('^file:///(.*)$') or uri
  else
    return uri:match('^file://(.*)$') or uri
  end
end

M.methods['textDocument/completion'] = {
  capability = {
    triggerCharacters = { '.' },
    completionItem = {
      labelDetailsSupport = true,
    },
  },
  handler = function(_, params, done)
    local items = {}

    vim.fn['nim#suggest#utils#Query'](
      'sug',
      {
        on_data = function(reply)
          for _, item in ipairs(reply) do
            local parts = vim.split(item, '\t',
              { plain = true, trimempty = false })
            if parts[1] == 'sug' then
              local kind = get_completion_item_kind(parts[2])
              local name = parts[3]
              local name_parts = vim.split(name, '.', { plain = true })
              local label = name_parts[#name_parts]
              local description = vim.fn.eval(parts[8])
              local editFormat = vim.lsp.protocol.InsertTextFormat.PlainText
              local textEdit
              if kind == vim.lsp.protocol.CompletionItemKind.Function or
                kind == vim.lsp.protocol.CompletionItemKind.Method
              then
                local param_count = 0
                local param_string = parts[4]:match('%b()')
                  :sub(2, -2)
                  :gsub('%b()', '')
                  :gsub('%b[]', '')
                if params.context.triggerKind ==
                    vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter
                then
                  param_string = param_string:gsub('^([%w_]+): [%w:_ ]+,?', '')
                end
                param_string = param_string:gsub('([%w_]+): [%w:_ ]+',
                  function(param_name)
                    param_count = param_count + 1
                    return '${'..param_count..':'..param_name..'}'
                  end)
                editFormat = vim.lsp.protocol.InsertTextFormat.Snippet
                textEdit = {
                  range = { ['end'] = params.position, start = params.position },
                  newText = label..'('..vim.fn.trim(param_string)..')$0',
                }
              end
              table.insert(items, {
                kind = kind,
                detail = parts[4],
                documentation = {
                  kind = 'markdown',
                  value = '-\n'..vim.fn.join({
                    '*'..parts[5]..'*',
                    #description > 0 and description or nil,
                  }, '\n\n'),
                },
                insertTextFormat = editFormat,
                label = label,
                labelDetails = {
                  description = name,
                },
                textEdit = textEdit,
              })
            end
          end
        end,
        on_end = function()
          done(items)
        end,
        pos = { params.position.line + 1, params.position.character + 1 },
      },
      false,
      true)
  end,
}

M.methods['textDocument/didChange'] = {
  handler = function(message_id, params)
    local did_change = M.methods['textDocument/didChange']

    local path = uri_to_path(params.textDocument.uri)
    local diag_stack = M.info.diag_stack[path]

    if diag_stack and #diag_stack > 0 then
      table.insert(diag_stack, {
        message_id = message_id,
        params = params,
      })
    else
      M.info.diag_stack[path] = {{
        message_id = message_id,
        params = params,
      }}

      local buf = get_or_open_buf(path)
      local ns = vim.api.nvim_create_namespace('nim_lsp')

      vim.diagnostic.set(ns, buf, {})

      vim.fn['nim#suggest#utils#Query'](
        'chk',
        {
          buffer = buf,
          on_data = function(reply)
            local cur_stack = M.info.diag_stack[path]
            if #cur_stack == 1 and cur_stack[1].message_id == message_id then
              local diagnostics = {}
              for _, item in ipairs(reply) do
                local parts = vim.split(item, '\t',
                  { plain = true, trimempty = false })
                if parts[1] == 'chk' then
                  table.insert(diagnostics, {
                    col = tonumber(parts[7]),
                    filename = parts[5],
                    lnum = tonumber(parts[6]) - 1,
                    message = vim.fn.eval(parts[8]),
                    severity = name_to_severity(parts[4]),
                    source = 'nim_lsp',
                  })
                end
              end
              apply_diagnostics(ns, diagnostics)
            end
          end,
          on_end = function()
            local cur_stack = M.info.diag_stack[path]
            local stack_count = #cur_stack
            if stack_count > 1 then
              local last_task = cur_stack[stack_count]
              M.info.diag_stack[path] = {}
              did_change.handler(last_task.message_id, last_task.params)
            else
              M.info.diag_stack[path] = {}
            end
          end,
        },
        false,
        true)
    end
  end,
}

M.methods['textDocument/didOpen'] = {
  handler = function(message_id, params)
    local did_change = M.methods['textDocument/didChange']

    local instance = vim.fn['nim#suggest#ProjectFindOrStart']()
    if type(instance) == 'table'
        and type(instance.file) == 'string'
    then
      local project = instance.file
      if not M.info.proj_cache[project] then
        M.info.proj_cache[project] = true
        params.textDocument.uri = path_to_uri(project)
        did_change.handler(message_id, params)
      else
        did_change.handler(message_id, params)
      end
    else
      did_change.handler(message_id, params)
    end
  end,
}

M.methods['textDocument/definition'] = {
  capability = true,
  handler = function(_, params, done)
    local definitions = {}

    vim.fn['nim#suggest#utils#Query'](
      'def',
      {
        on_data = function(reply)
          for _, item in ipairs(reply) do
            local parts = vim.split(item, '\t',
              { plain = true, trimempty = false })
            if parts[1] == 'def' then
              table.insert(definitions, {
                uri = path_to_uri(parts[5]),
                range = {
                  start = {
                    character = tonumber(parts[7]),
                    line = tonumber(parts[6]) - 1,
                  },
                },
              })
            end
          end
        end,
        on_end = function()
          if #definitions == 1 then
            done(definitions[1])
          else
            done(definitions or {})
          end
        end,
        pos = { params.position.line + 1, params.position.character + 1 },
      },
      false,
      true)
  end,
}

M.methods['textDocument/hover'] = {
  capability = true,
  handler = function(_, params, done)
    vim.fn['nim#suggest#utils#Query'](
      'def',
      {
        on_data = function(reply)
          local documentation

          for _, item in ipairs(reply) do
            local parts = vim.split(item, '\t',
              { plain = true, trimempty = false })
            if parts[1] == 'def' then
              local description = vim.fn.eval(parts[8])
              documentation = '```nim\n'
                ..parts[3]..': '
                ..prettify_param_string(parts[4])
                ..'\n```\n'
                ..'-\n'..vim.fn.join({
                  '*'..parts[5]..'*',
                  #description > 0 and description or nil,
                }, '\n\n')
              break
            end
          end

          done {
            contents = {
              kind = 'markdown',
              value = documentation,
            },
          }
        end,
        pos = { params.position.line + 1, params.position.character + 1 },
      },
      false,
      true)
  end,
}

M.methods['textDocument/references'] = {
  capability = true,
  handler = function(_, params, done)
    vim.fn['nim#suggest#utils#Query'](
      'use',
      {
        on_data = function(reply)
          local references = {}

          for _, item in ipairs(reply) do
            local parts = vim.split(item, '\t',
              { plain = true, trimempty = false })
            if parts[1] == 'use' then
              table.insert(references, {
                uri = path_to_uri(parts[5]),
                range = {
                  start = {
                    character = tonumber(parts[7]),
                    line = tonumber(parts[6]) - 1,
                  },
                },
              })
            end
          end

          done(references)
        end,
        pos = { params.position.line + 1, params.position.character + 1 },
      },
      false,
      true)
  end,
}

M.methods['textDocument/rename'] = {
  capability = true,
  handler = function(_, params, done)
    local path = uri_to_path(params.textDocument.uri)
    local buf = get_or_open_buf(path)
    local word, word_pos = get_word_at(
      buf,
      params.position.line + 1,
      params.position.character)

    if word then
      local changes

      vim.fn['nim#suggest#utils#Query'](
        'use',
        {
          on_data = function(reply)
            if not changes then
              changes = {
                [path] = {{
                  newText = params.newName,
                  range = {
                    ['end'] = {
                      character = word_pos + #word,
                      line = params.position.line,
                    },
                    start = {
                      character = word_pos,
                      line = params.position.line,
                    },
                  },
                }},
              }
            else
              changes = {}
            end

            for _, item in ipairs(reply) do
              local parts = vim.split(item, '\t',
                { plain = true, trimempty = false })
              if parts[1] == 'use' then
                local filename = parts[5]
                local edits = changes[filename]
                if not edits then
                  edits = {}
                  changes[filename] = edits
                end

                local lnum = tonumber(parts[6])
                local col = tonumber(parts[7])

                table.insert(edits, {
                  newText = params.newName,
                  range = {
                    ['end'] = {
                      character = col + #word,
                      line = lnum - 1,
                    },
                    start = {
                      character = col,
                      line = lnum - 1,
                    },
                  },
                })
              end
            end

            done{ changes = changes }
          end,
          pos = { params.position.line + 1, params.position.character + 1 },
        },
        false,
        true)
    else
      done()
    end
  end,
}

local function get_lsp_capabilities(methods)
  local capabilities = {
    textDocumentSync = {
      change = vim.lsp.protocol.TextDocumentSyncKind.Full,
      openClose = true,
    },
  }

  for method, def in pairs(methods) do
    local capability = def.capability
    if capability then
      local name = method:match('textDocument/(%w+)')
      if name then
        capabilities[name..'Provider'] = capability
      end
    end
  end

  return capabilities
end

function M.cmd()
  local message_id = 1
  local is_stopped = false

  local function handler(method, params, callback, notify_callback)
    message_id = message_id + 1

    local function send(result)
      if callback then
        callback(nil, result)
      end
    end

    if method == 'initialize' then
      send{ capabilities = get_lsp_capabilities(M.methods) }
    elseif method == 'shutdown' then
      is_stopped = true
      send()
    elseif method == 'exit' then
      vim.fn['nim#suggest#ProjectStopAll']()
      M.info.proj_cache = {}
      send()
    else
      local def = M.methods[method]

      if def then
        def.handler(message_id, params, send)
      else
        send()
      end
    end

    if notify_callback then
      notify_callback(message_id)
    end

    return true, message_id
  end

  return {
    is_closing = function()
      return is_stopped
    end,
    notify = handler,
    request = handler,
    terminate = function()
      is_stopped = true
    end,
  }
end

return M
