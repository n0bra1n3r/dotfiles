function plug.config()
  local cmp = require'cmp'
  cmp.setup {
    formatting = {
      format = function(entry, vim_item)
        if vim.tbl_contains({ "path" }, entry.source.name) then
          local icon, hl_group = require'nvim-web-devicons'.get_icon(entry:get_completion_item().label)
          if icon then
            vim_item.kind = icon
            vim_item.kind_hl_group = hl_group
            return vim_item
          end
        end
        return require'lspkind'.cmp_format({
          mode = "symbol",
          maxwidth = 50,
          ellipsis_char = '...',
        })(entry, vim_item)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping {
        c = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
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
