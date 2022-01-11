local M = {}

function M.config()
  require"packer".init {
    auto_clean = true,
    compile_on_sync = true,
    display = {
      open_cmd = "vnew \\[packer\\] | wincmd L | vertical resize 50",
      keybindings = {
        quit = "<ESC>",
      },
    },
    git = {
      clone_timeout = 6000,
    },
  }
end

return M
