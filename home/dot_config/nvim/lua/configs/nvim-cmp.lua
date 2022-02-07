local M = {}

function M.config()
  require"cmp".setup {
    completion = {
      autocomplete = false,
      completeopt = "menu,menuone",
    },
    experimental = {
      ghost_text = true,
    },
    formatting = {
      format = function(entry, vim_item)
        if entry.source.name == 'nvim_lsp' then
          vim_item.dup = 0
        end
        return require"lspkind".cmp_format({
          maxwidth = 50,
        })(entry, vim_item)
      end
    },
    mapping = {
      ["<C-p>"] = require"cmp".mapping.select_prev_item(),
      ["<C-n>"] = require"cmp".mapping.select_next_item(),
      ["<C-d>"] = require"cmp".mapping.scroll_docs(-4),
      ["<C-f>"] = require"cmp".mapping.scroll_docs(4),
      ["<C-Space>"] = require"cmp".mapping.complete(),
      ["<C-e>"] = require"cmp".mapping.close(),
      ["<CR>"] = require"cmp".mapping.confirm {
        behavior = require"cmp".ConfirmBehavior.Replace,
        select = true,
      },
      ["<Tab>"] = function(fallback)
        if require"cmp".visible() then
          require"cmp".select_next_item({ behavior = "select" })
          if require"cmp".get_selected_entry() == nil then
            require"cmp".select_next_item({ behavior = "select" })
          end
        elseif require"luasnip".expand_or_jumpable() then
          require"luasnip".expand_or_jump()
        else
          fallback()
        end
      end,
      ["<S-Tab>"] = function(fallback)
        if require"cmp".visible() then
          require"cmp".select_prev_item({ behavior = "select" })
          if require"cmp".get_selected_entry() == nil then
            require"cmp".select_prev_item({ behavior = "select" })
          end
        elseif require"luasnip".jumpable(-1) then
          require"luasnip".jump(-1)
        else
          fallback()
        end
      end,
    },
    snippet = {
      expand = function(args)
        require"luasnip".lsp_expand(args.body)
      end,
    },
    sorting = {
      comparators = {
        require"cmp".config.compare.score,
        require"cmp".config.compare.offset,
        require"cmp".config.compare.recently_used,
      },
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
    },
  }
end

return M
