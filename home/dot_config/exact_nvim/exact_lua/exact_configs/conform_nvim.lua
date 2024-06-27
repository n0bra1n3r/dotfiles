return {
  config = function()
    require'conform'.setup {
      format_on_save = {
        lsp_format = 'fallback',
        timeout_ms = 500,
      },
      formatters_by_ft = {
        nim = { 'nph' },
        swift = { 'swiftformat' },
      },
      formatters = {
        nph = {
          args = { '-' },
          command = 'nph',
          stdin = true,
        },
      },
    }
  end,
}
