return {
  config = function()
    require'neodev'.setup {
      override = function(root_dir, options)
        if root_dir:find"chezmoi" then
          options.enabled = true
          options.runtime = true
          options.types = true
          options.plugins = true
        end
      end,
    }
  end,
}
