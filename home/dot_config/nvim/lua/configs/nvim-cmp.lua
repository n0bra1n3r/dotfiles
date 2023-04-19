function plug.config()
  require'cmp'.setup {
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
    mapping = require'cmp'.mapping.preset.insert {
      ["<C-Space>"] = require'cmp'.mapping.complete(),
      ["<CR>"] = require'cmp'.mapping {
        c = require'cmp'.mapping.confirm {
          behavior = require'cmp'.ConfirmBehavior.Replace,
          select = true,
        },
        i = function(fallback)
         if require'cmp'.visible() and require'cmp'.get_selected_entry() ~= nil then
           require'cmp'.confirm {
             behavior = require'cmp'.ConfirmBehavior.Replace,
             select = false,
           }
         else
           fallback()
         end
        end,
        s = require'cmp'.mapping.confirm{ select = true },
      },
      ["<Tab>"] = require'cmp'.mapping(function(fallback)
        if require'cmp'.visible() then
          require'cmp'.select_next_item {
            behavior = require'cmp'.SelectBehavior.Select,
          }
          if #require'cmp'.get_entries() == 1 then
            require'cmp'.confirm {
              behavior = require'cmp'.ConfirmBehavior.Replace,
              select = false,
            }
          end
        else
          fallback()
        end
      end, { "c", "i", "s" }),
      ["<S-Tab>"] = require'cmp'.mapping(function(fallback)
        if require'cmp'.visible() then
          require'cmp'.select_prev_item {
            behavior = require'cmp'.SelectBehavior.Select,
          }
        else
          fallback()
        end
      end, { "c", "i", "s" }),
    },
    sources = require'cmp'.config.sources(
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
      completion = require'cmp'.config.window.bordered(),
      documentation = require'cmp'.config.window.bordered(),
    },
  }
  require'cmp'.setup.cmdline({ "/", "?" }, {
    mapping = require'cmp'.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" }
    }
  })
  require'cmp'.setup.cmdline(":", {
    mapping = require'cmp'.mapping.preset.cmdline(),
    sources = require'cmp'.config.sources(
      { { name = "path" } },
      { { name = "cmdline" } }
    )
  })
end
