local M = {}

function M.config()
  local CompletionItemKind = vim.lsp.protocol.CompletionItemKind
  local kinds = {
    d = CompletionItemKind.Keyword,
    f = CompletionItemKind.Function,
    t = CompletionItemKind.Struct,
    v = CompletionItemKind.Variable,
  }

  local nim_completion = require"null-ls.helpers".make_builtin {
    method = require"null-ls".methods.COMPLETION,
    filetypes = { "nim" },
    generator = {
      async = true,
      fn = function(params, done)
        vim.fn["nim#suggest#sug#GetAllCandidates"](function(start, candidates)
          local items = vim.tbl_map(function(candidate)
            return {
              kind = kinds[candidate.kind] or CompletionItemKind.Text,
              label = candidate.word,
              documentation = candidate.info,
            }
          end, candidates)
          done { { items = items } }
        end)
      end,
    },
  }

  require"null-ls".setup {
    sources = {
      nim_completion
    },
  }
end

return M
