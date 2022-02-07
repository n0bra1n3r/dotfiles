local M = {}

function M.config()
  require"which-key".setup {
    window = {
      border = "single",
      margin = { 0, 0, 0, 0 },
      padding = { 0, 0, 0, 0 },
      position = "top",
    },
  }
  require"which-key".register({
    ["<leader>"] = {
      ["%"] = { ":%s///gc<Left><Left><Left>", "replace", silent = false },
      g = {
        name = "git",
        g = { "<cmd>lua fn.open_git_shell()<CR>", "git shell" },
        d = { "<cmd>DiffviewOpen<CR>", "git diff" },
        h = { "<cmd>DiffviewFileHistory<CR>", "file history" },
      },
      d = {
        name = "debug",
        b = { "<cmd>lua fn.debug_break()<CR>", "break" },
        c = { "<cmd>lua fn.debug_continue()<CR>", "continue" },
        D = { "<cmd>lua fn.project_debug()<CR>", "restart" },
        d = { "<cmd>lua fn.debug_step()<CR>", "step" },
        s = { "<cmd>lua fn.debug_show_symbol()<CR>", "symbol" },
        S = { "<cmd>lua fn.debug_show_symbols()<CR>", "symbols" },
        x = { "<cmd>lua fn.debug_exit()<CR>", "exit" }
      },
      r = {
        name = "runner",
        b = { "<cmd>lua fn.project_build()<CR>", "build" },
        D = { "<cmd>lua fn.project_debug()<CR>", "debug" },
        d = { "<cmd>lua fn.project_build_and_debug()<CR>", "build and debug" },
        R = { "<cmd>lua fn.project_run()<CR>", "run" },
        r = { "<cmd>lua fn.project_build_and_run()<CR>", "build and run" },
        s = { "<cmd>lua fn.open_run_shell()<CR>", "shell" },
      },
      s = {
        name = "search",
        b = { "<cmd>Telescope buffers<CR>", "search buffers" },
        f = { "<cmd>Telescope find_files<CR>", "search files" },
        s = { "<cmd>lua fn.show_string_search_picker()<CR>", "search strings" },
        t = { "<cmd>TodoTelescope<CR>", "search todos" },
      },
      p = {
        name = "packages",
        p = { "<cmd>PackerSync<CR>", "sync packages" },
      },
      q = {
        name = "quickfix",
        q = { "<cmd>lua fn.toggle_quickfix()<CR>", "quickfix list" },
        n = { "<cmd>cnext<CR>", "next issue" },
        N = { "<cmd>cprev<CR>", "prev issue" },
      },
      R = { "<cmd>lua fn.reload_config()<CR>", "reload" },
      t = { "<cmd>NvimTreeToggle<CR>", "tree" },
      w = { "<cmd>lua fn.choose_window()<CR>", "window" },
      x = { "<cmd>lua fn.close_buffer()<CR>", "close" },
      z = { "<cmd>only<CR>", "zoom" },
    },
  }, { mode = "n" })
end

return M
