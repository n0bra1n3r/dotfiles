return {
  config = function()
    require'portal'.setup {
      filter = function(result)
        return fn.is_file_buffer(result.buffer)
      end,
      labels = { [[]] },
      max_results = 1,
    }
  end
}
