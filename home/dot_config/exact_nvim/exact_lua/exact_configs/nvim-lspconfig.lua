local function goto_definition(win_cmd)
  return function()
    if win_cmd then
      vim.cmd(win_cmd)
    end
    vim.lsp.buf.definition {
      on_list = function(options)
        vim.fn.setqflist({}, ' ', options)
        vim.cmd.copen()
      end,
      reuse_win = true,
    }
  end
end

local function format()
  vim.lsp.buf.format{ async = true }
end

return {
  config = function()
    local lsp = require'lsp-zero'

    local severities = {
      [vim.diagnostic.severity.ERROR] = 'Error',
      [vim.diagnostic.severity.WARN] = 'Warn',
      [vim.diagnostic.severity.HINT] = 'Hint',
      [vim.diagnostic.severity.INFO] = 'Info',
    }

    lsp.on_attach(function(_, bufnr)
      local function map(m, lhs, rhs, desc)
        vim.api.nvim_buf_set_keymap(bufnr, m, lhs, [[]], {
          callback = rhs,
          desc = desc,
          noremap = true,
        })
      end

      map('n', 'K', vim.lsp.buf.hover)
      map('n', 'gd', goto_definition(), "Go to definition")
      map('n', '<C-w><C-f>', goto_definition('vsplit'), "Go to definition in vertical split")
      map('n', '<C-w>f', goto_definition('split'), "Go to definition in split")
      map('n', '<C-w>gf', goto_definition('tab split'), "Go to definition in new tab")
      map('n', 'gR', vim.lsp.buf.references, "Show symbol references")
      map('n', '<F2>', vim.lsp.buf.rename)
      map('n', '<F3>', format)
      map('x', '<F3>', format)
      map('n', '<F4>', vim.lsp.buf.code_action)

      if vim.lsp.buf.range_code_action then
        map('x', '<F4>', vim.lsp.buf.range_code_action)
      else
        map('x', '<F4>', vim.lsp.buf.code_action)
      end

      map('n', '[s', vim.diagnostic.goto_prev, "Go to next diagnostic")
      map('n', ']s', vim.diagnostic.goto_next, "Go to previous diagnostic")
    end)

    vim.diagnostic.config(lsp.defaults.diagnostics {
      signs = false,
      update_in_insert = false,
      virtual_text = false,
    })

    vim.diagnostic.handlers.virtual_lines = {
      show = function(namespace, bufnr, diagnostics)
        local ns = vim.diagnostic.get_namespace(namespace)
        if not ns.user_data.virt_lines_ns then
          ns.user_data.virt_lines_ns = vim.api.nvim_create_namespace('')
        end
        local virt_lines_ns = ns.user_data.virt_lines_ns

        vim.api.nvim_buf_clear_namespace(bufnr, virt_lines_ns, 0, -1)

        for _, diagnostic in ipairs(diagnostics) do
          local name = severities[diagnostic.severity]
          local sign = vim.fn.sign_getdefined('DiagnosticSign'..name)[1]
          local sign_hl = 'DiagnosticSign'..name
          local text_hl = 'DiagnosticVirtualText'..name

          pcall(vim.api.nvim_buf_set_extmark, bufnr, virt_lines_ns, diagnostic.lnum, diagnostic.col, {
            end_col = diagnostic.end_col,
            end_row = diagnostic.end_lnum,
            hl_mode = 'combine',
            hl_group = text_hl,
            virt_text = {{ sign.text, sign_hl }},
          })
        end
      end,
      hide = function(namespace, bufnr)
        local ns = vim.diagnostic.get_namespace(namespace)
        if ns.user_data.virt_lines_ns then
          vim.api.nvim_buf_clear_namespace(
            bufnr,
            ns.user_data.virt_lines_ns,
            0,
            -1
          )
        end
      end,
    }

    local config = require'lspconfig'
    local default_config = function(name)
      local is_ok, module = pcall(require, 'lspconfig.server_configurations.'..name);
      return is_ok and module.default_config
    end

    require'mason-lspconfig'.setup {
      ensure_installed = {
        'bashls',
        'graphql',
        'jsonls',
        'kotlin_language_server',
        'lua_ls',
        'marksman',
        'pyright',
      },
      handlers = {
        function(server)
          config[server].setup{}
        end,
        lua_ls = function()
          config.lua_ls.setup(lsp.nvim_lua_ls {
            root_dir = function(fname)
              if fname:match('/%.nvim/init%.lua$') then
                return vim.fn.expand'~/.config/nvim/lua'
              else
                ---@diagnostic disable-next-line: undefined-field
                return default_config'lua_ls'.root_dir(fname)
              end
            end,
          })
        end,
      },
    }

    config.sourcekit.setup {
      cmd = {
        'xcrun',
        '--toolchain',
        'swift',
        'sourcekit-lsp',
      },
    }

    require'lspconfig.configs'.nim_lsp = {
      default_config = {
        cmd = fn.nim_lsp,
        filetypes = { 'nim' },
        root_dir = function()
          return vim.fn.getcwd()
        end,
      },
    }

    config.nim_lsp.setup{}

    lsp.setup()
  end,
}
