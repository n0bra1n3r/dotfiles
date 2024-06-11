local M = {
  info = {
    diag_stack = {},
    is_stopped = false,
    line_cache = {},
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

local function get_word_at(buf, line, col, lines)
  local line_text = lines and lines[line] or
    vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
  if line_text then
    local prefix = line_text:sub(1, col):match('[%w_]+$')
    local suffix = line_text:sub(col + 1):match('^[%w_]+')
    if not prefix then return suffix, col end
    return prefix..(suffix or ''), col - #prefix
  end
end

local function get_token_at(buf, line, col, lines)
  local line_text = lines and lines[line] or
    vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
  if line_text then
    local line_part = line_text:sub(col + 1)
    local token_start = line_part:sub(1, 1)
    local token_end = ({
      ["'"] = "'",
      ['"'] = '"',
      ['('] = ')',
      ['{'] = '}',
      ['['] = ']',
    })[token_start]
    return token_end and
      line_part:match([[%b]]..token_start..token_end) or
      get_word_at(buf, line, col, lines)
  end
end

local function get_cached_lines(buf)
  local lines = M.info.line_cache[''..buf]
  if not lines then
    lines = vim.fn.readfile(vim.api.nvim_buf_get_name(buf))
    M.info.line_cache[''..buf] = lines
  end
  return lines
end

local function apply_diagnostics(ns, diagnostics)
  local bufs = {}
  for _, diagnostic in ipairs(diagnostics) do
    local buf = diagnostic.bufnr or get_or_open_buf(diagnostic.filename)
    if buf ~= -1 then
      local buf_diagnostics = bufs[buf]
      if not buf_diagnostics then
        buf_diagnostics = {}
        bufs[buf] = buf_diagnostics
      end
      if not diagnostic.end_col or diagnostic.end_col == diagnostic.col then
        local lines = not vim.api.nvim_buf_is_loaded(buf) and get_cached_lines(buf)
        local token = get_token_at(buf, diagnostic.lnum + 1, diagnostic.col, lines)
        if token then
          diagnostic.end_col = diagnostic.col + #token
        end
      end
      diagnostic.source = 'nim_lsp'
      table.insert(buf_diagnostics, diagnostic)
    end
  end
  for buf, buf_diagnostics in pairs(bufs) do
    vim.diagnostic.set(ns, buf, buf_diagnostics)
  end
end

local function path_to_uri(path)
  if vim.fn.has('win32') == 1 then
    return 'file:///'..path
  else
    return 'file://'..path
  end
end

local function prettify_param_string(string)
  local indent = '  '
  local params = string:match('%b()')
  if not params then
    return string
  end
  local prefix = string:match('^([%w_]+)') or ''
  local suffix = vim.trim(string:sub(#prefix + 1) or '')
  suffix = vim.trim(suffix:sub(#params + 1) or '')
  local pragma = suffix:match('%b{}$') or ''
  suffix = vim.trim(suffix:sub(1, -#pragma - 1))
  if #pragma > 0 then
    suffix = suffix..'\n'
      ..indent..indent
      ..pragma
  end
  local params_parts = vim.split(params, ',')
  params_parts = vim.tbl_map(vim.trim, params_parts)
  if #params_parts <= 1 then
    return prefix..params..suffix
  end
  local result = prefix..'(\n'..indent
  result = result..vim.fn.join(params_parts, ',\n'..indent):sub(2)
  result = result..suffix
  return result
end

local function uri_to_path(uri)
  if vim.fn.has('win32') == 1 then
    return uri:match('^file:///(.*)$') or uri
  else
    return uri:match('^file://(.*)$') or uri
  end
end

-- M.methods['textDocument/completion'] = {
--   capability = {
--     triggerCharacters = { '.' },
--     completionItem = {
--       labelDetailsSupport = true,
--     },
--   },
--   handler = function(_, params, cb)
--     local items = {}
--
--     vim.fn['nim#suggest#utils#Query'](
--       'sug',
--       {
--         on_data = function(reply)
--           for _, item in ipairs(reply) do
--             local parts = vim.split(item, '\t',
--               { plain = true, trimempty = false })
--             if parts[1] == 'sug' then
--               local kind = get_completion_item_kind(parts[2])
--               local name = parts[3]
--               local name_parts = vim.split(name, '.', { plain = true })
--               local label = name_parts[#name_parts]
--               local description = vim.fn.eval(parts[8])
--               local editFormat = vim.lsp.protocol.InsertTextFormat.PlainText
--               local textEdit
--               if kind == vim.lsp.protocol.CompletionItemKind.Function or
--                 kind == vim.lsp.protocol.CompletionItemKind.Method
--               then
--                 local param_count = 0
--                 local param_string = parts[4]:match('%b()')
--                   :sub(2, -2)
--                   :gsub('%b()', '')
--                   :gsub('%b[]', '')
--                 if params.context.triggerKind ==
--                     vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter
--                 then
--                   param_string = param_string:gsub('^([%w_]+): [%w:_ ]+,?', '')
--                 end
--                 param_string = param_string:gsub('([%w_]+): [%w:_ ]+',
--                   function(param_name)
--                     param_count = param_count + 1
--                     return '${'..param_count..':'..param_name..'}'
--                   end)
--                 editFormat = vim.lsp.protocol.InsertTextFormat.Snippet
--                 textEdit = {
--                   newText = label..'('..vim.fn.trim(param_string)..')$0',
--                   range = { ['end'] = params.position, start = params.position },
--                 }
--               end
--               table.insert(items, {
--                 kind = kind,
--                 detail = parts[4],
--                 documentation = {
--                   kind = 'markdown',
--                   value = '-\n'..vim.fn.join({
--                     '*'..parts[5]..'*',
--                     #description > 0 and description or nil,
--                   }, '\n\n'),
--                 },
--                 insertTextFormat = editFormat,
--                 label = label,
--                 labelDetails = {
--                   description = name,
--                 },
--                 textEdit = textEdit,
--               })
--             end
--           end
--         end,
--         on_end = function()
--           cb.send(items)
--         end,
--         pos = { params.position.line + 1, params.position.character + 1 },
--       },
--       false,
--       true)
--   end,
-- }

-- M.methods['textDocument/didChange'] = {
--   handler = function(_, params, cb)
--     local text = params.contentChanges and
--       params.contentChanges[#params.contentChanges].text or
--       params.textDocument.text
--     if text and #text > 0 then
--       local path = uri_to_path(params.textDocument.uri)
--
--       local ns = vim.api.nvim_create_namespace('nim_lsp')
--
--       local diagnostics = {}
--       local info_cache = {}
--       local last_diagnostic
--
--       local job = require'plenary.job':new{
--         args = {
--           'check',
--           '--verbosity:0',
--           '--eval:',
--           text,
--         },
--         command = 'nim',
--         cwd = vim.fn.fnamemodify(path, ':h'),
--         on_exit = function()
--           table.remove(M.info.diag_stack, 1)
--           cb.stop{ message = 'diagnostics', percentage = 100 }
--
--           if #M.info.diag_stack > 0 then
--             M.info.diag_stack[1]:start()
--             cb.start{ message = 'diagnostics' }
--           end
--         end,
--         on_stderr = vim.schedule_wrap(function(_, line)
--           if line then
--             local errors = vim.fn.getqflist{
--               lines = { line:gsub([[^cmdfile%.nim]], path) },
--               efm = [[%f(%l\, %c) %trror: %m,]]
--                 ..[[%f(%l\, %c) %tarning: %m,]]
--                 ..[[%N%f(%l\, %c) Hint: %m,]]
--                 ..[[%A%f(%l\, %c) %m,]]
--                 ..[[%-IHint: %m,]]
--                 ..[[%-EError: %m,]]
--                 ..[[%-ICC: %m,]]
--                 ..[[%-Istack trace: %m]]
--             }.items
--
--             for _, error in ipairs(errors) do
--               local diagnostic = vim.diagnostic.fromqflist{ error }[1]
--               if diagnostic then
--                 diagnostic.code = diagnostic.message:match('%[(%w+)%]$')
--                 if diagnostic.code then
--                   diagnostic.message = diagnostic.message:sub(1, -#diagnostic.code - 4)
--                 end
--
--                 if #error.type ~= 0 then
--                   if #info_cache > 0 then
--                     diagnostic.user_data = info_cache
--                     info_cache = {}
--                   end
--                   table.insert(diagnostics, diagnostic)
--                 else
--                   diagnostic.severity = vim.diagnostic.severity.INFO
--                   table.insert(info_cache, diagnostic)
--                 end
--
--                 last_diagnostic = diagnostic
--               elseif last_diagnostic then
--                 last_diagnostic.message = last_diagnostic.message
--                   ..'\n'
--                   ..error.text
--               end
--             end
--
--             apply_diagnostics(ns, diagnostics)
--           end
--         end),
--       }
--
--       if #M.info.diag_stack < 2 then
--         table.insert(M.info.diag_stack, job)
--
--         if #M.info.diag_stack < 2 then
--           M.info.diag_stack[1]:start()
--           cb.start{ message = 'diagnostics' }
--         end
--       else
--         M.info.diag_stack[2] = job
--       end
--     end
--   end,
-- }
--
-- M.methods['textDocument/didOpen'] = {
--   handler = function(message_id, params, cb)
--     local did_change = M.methods['textDocument/didChange']
--     did_change.handler(message_id, params, cb)
--   end,
-- }

M.methods['textDocument/definition'] = {
  capability = true,
  handler = function(_, params, cb)
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
            cb.send(definitions[1])
          else
            cb.send(definitions or {})
          end
        end,
        pos = { params.position.line + 1, params.position.character + 1 },
      },
      false,
      true)
  end,
}

M.methods['textDocument/formatting'] = {
  capability = 'documentFormatting',
  handler = function(_, params, cb)
    cb.start{ message = 'formatting' }

    local path = uri_to_path(params.textDocument.uri)
    local buf = get_or_open_buf(path)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local text = vim.fn.join(lines, '\n')
    local new_lines = vim.fn.systemlist('nph -', text)

    if vim.v.shell_error == 0
        and not vim.deep_equal(new_lines, lines)
    then
      cb.send{{
        newText = vim.fn.join(new_lines, '\n'),
        range = {
          ['end'] = { character = 0, line = #lines },
          start = { character = 0, line = 0 },
        },
      }}
    else
      cb.send()
    end

    cb.stop{ message = 'formatting', percentage = 100 }
  end,
}

M.methods['textDocument/hover'] = {
  capability = true,
  handler = function(_, params, cb)
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

          cb.send {
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
  handler = function(_, params, cb)
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

          cb.send(references)
        end,
        pos = { params.position.line + 1, params.position.character + 1 },
      },
      false,
      true)
  end,
}

M.methods['textDocument/rename'] = {
  capability = true,
  handler = function(_, params, cb)
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

            cb.send{ changes = changes }
          end,
          pos = { params.position.line + 1, params.position.character + 1 },
        },
        false,
        true)
    else
      cb.send()
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
      if type(capability) == 'boolean' or type(capability) == 'table' then
        local name
        if type(capability) == 'table' then
          name = capability[1]
        end
        name = name or method:match('textDocument/(%w+)')
        if name then
          capabilities[name..'Provider'] = capability
        end
      elseif type(capability) == 'string' then
        ---@diagnostic disable-next-line: assign-type-mismatch
        capabilities[capability..'Provider'] = true
      end
    end
  end

  return capabilities
end

function M.cmd(get_client_id)
  local note_cache = { token = nil }

  local message_id = 1

  local function handler(method, params, callback, notify_callback)
    message_id = message_id + 1

    local function send(result)
      if callback then
        callback(nil, result)
      end
    end

    local function progress(token, kind, opts)
      vim.schedule(function()
        vim.lsp.handlers['$/progress'](nil, {
          token = token,
          value = vim.tbl_extend('keep', { kind = kind }, opts or {}),
        }, { client_id = get_client_id() })
      end)
    end

    if method == 'initialize' then
      send{ capabilities = get_lsp_capabilities(M.methods) }
    elseif method == 'shutdown' then
      M.info.is_stopped = true
      send()
    elseif method == 'exit' then
      vim.fn['nim#suggest#ProjectStopAll']()
      send()
    else
      local def = M.methods[method]

      if def then
        def.handler(message_id, params, {
          report = function(opts)
            if note_cache.token then
              progress(note_cache.token, 'report', opts)
            end
          end,
          start = function(opts)
            if not note_cache.token then
              note_cache.token = message_id
              progress(note_cache.token, 'begin', opts)
            end
          end,
          stop = function(opts)
            if note_cache.token then
              if opts and opts.percentage then
                progress(note_cache.token, 'report', opts)
              end
              progress(note_cache.token, 'end', opts)
              note_cache.token = nil
            end
          end,
          send = send,
        })
      else
        send()
      end
    end

    if notify_callback then
      notify_callback(message_id)
    end

    return true, message_id
  end

  return function()
    return {
      is_closing = function()
        return M.info.is_stopped
      end,
      notify = handler,
      request = handler,
      terminate = function()
        M.info.is_stopped = true
      end,
    }
  end
end

return M
