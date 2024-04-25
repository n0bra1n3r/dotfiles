return {
  config = function()
    require'grapple'.setup {
      scope = 'workspace',
      save_path = '.nvim/favorites',
      scopes = {
        {
          name = 'workspace',
          desc = "Current workspace directory",
          fallback = 'cwd',
          cache = {
            event = { 'DirChanged' },
          },
          resolver = function()
            local dir = fn.get_workspace_dir()
            return dir, dir
          end,
        }
      },
    }
  end,
}
