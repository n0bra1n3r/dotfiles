local M = {}

function M.config()
  require"presence":setup {
    auto_update = fn.is_git_dir(),
    git_commit_text = "Committing changes to %s",
    neovim_image_text = "Neovim",
    main_image = "file",
  }
end

return M
