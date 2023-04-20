local kind_icons = {
  Text = '',
  Method = '',
  Function = '',
  Constructor = '',
  Field = '',
  Variable = '',
  Class = 'ﴯ',
  Interface = '',
  Module = '',
  Property = 'ﰠ',
  Unit = '',
  Value = '',
  Enum = '',
  Keyword = '',
  Snippet = '',
  Color = '',
  File = '',
  Reference = '',
  Folder = '',
  EnumMember = '',
  Constant = '',
  Struct = '',
  Event = '',
  Operator = '',
  TypeParameter = ''
}
local menu_icons = {
  nvim_lsp = 'λ',
  luasnip = '⋗',
  buffer = 'Ω',
  path = '🖫',
  nvim_lua = 'Π',
}

function plug.config()
  require'lsp-zero.cmp'.extend()
  local cmp = require'cmp'
  cmp.setup {
    formatting = {
      expandable_indicator = false,
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        if vim.tbl_contains({ "path" }, entry.source.name) then
          local icon, hl_group = require'nvim-web-devicons'.get_icon(entry:get_completion_item().label)
          if icon then
            vim_item.kind = icon
            vim_item.kind_hl_group = hl_group
            return vim_item
          end
        end
        vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind:sub(1, 1)
        vim_item.menu = menu_icons[entry.source.name]
        return vim_item
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping {
        c = function(fallback)
          if cmp.visible() and cmp.get_selected_entry() ~= nil then
            cmp.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            }
          else
            fallback()
          end
        end,
        i = function(fallback)
          if cmp.visible() and cmp.get_selected_entry() ~= nil then
            cmp.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            }
          else
            fallback()
          end
        end,
        s = cmp.mapping.confirm{ select = true },
      },
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item {
            behavior = cmp.SelectBehavior.Select,
          }
          if #cmp.get_entries() == 1 then
            cmp.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            }
          end
        else
          fallback()
        end
      end, { "c", "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
          }
        else
          fallback()
        end
      end, { "c", "i", "s" }),
    },
    sources = cmp.config.sources(
      {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
      },
      {
        {
          name = "buffer",
          option = {
            get_bufnrs = function()
              local buf = vim.api.nvim_get_current_buf()
              local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
              if byte_size > 1024 * 1024 then -- 1 Megabyte max
                return {}
              end
              return { buf }
            end,
          },
        },
      }
    ),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  }
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" }
    }
  })
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
      { { name = "path" } },
      { { name = "cmdline" } }
    )
  })
end
