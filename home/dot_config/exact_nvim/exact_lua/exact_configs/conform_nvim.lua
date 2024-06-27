return {
  config = function()
    require 'conform'.setup {
      format_on_save = {
        lsp_format = 'fallback',
        timeout_ms = 500,
      },
      formatters_by_ft = {
        ['_'] = { 'trim_whitespace' },
        nim = { 'nph' },
        swift = { 'swiftformat' },
        yaml = { 'yamlfmt' },
      },
      formatters = {
        nph = {
          args = { '-' },
          command = 'nph',
          stdin = true,
        },
      },
    }

    vim.lsp.buf.format = require 'conform'.format
  end,
}
