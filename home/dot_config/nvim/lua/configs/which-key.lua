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
        b = { "<cmd>lua fn.show_git_line_blame()<CR>", "blame" },
        g = { "<cmd>lua fn.open_git_shell()<CR>", "shell" },
        d = { "<cmd>DiffviewOpen<CR>", "diff" },
        h = { "<cmd>DiffviewFileHistory<CR>", "history" },
      },
      d = {
        name = "debug",
        b = { "<cmd>lua fn.debug_break()<CR>", "break" },
        B = { "<cmd>lua fn.project_debug()<CR>", "restart" },
        c = { "<cmd>lua fn.debug_continue()<CR>", "continue" },
        d = { "<cmd>lua fn.debug_step()<CR>", "step" },
        s = { "<cmd>lua fn.debug_show_symbol()<CR>", "symbol" },
        S = { "<cmd>lua fn.debug_show_symbols()<CR>", "symbols" },
        x = { "<cmd>lua fn.debug_exit()<CR>", "exit" }
      },
      r = {
        name = "runner",
        b = { "<cmd>lua fn.project_build()<CR>", "build" },
        d = { "<cmd>lua fn.project_build_and_debug()<CR>", "build and debug" },
        D = { "<cmd>lua fn.project_debug()<CR>", "debug" },
        r = { "<cmd>lua fn.project_build_and_run()<CR>", "build and run" },
        R = { "<cmd>lua fn.project_run()<CR>", "run" },
        s = { "<cmd>lua fn.open_run_shell()<CR>", "shell" },
        t = { "<cmd>lua fn.project_test()<CR>", "test" },
      },
      s = {
        name = "search",
        b = { "<cmd>Telescope buffers<CR>", "buffers" },
        f = { "<cmd>Telescope find_files<CR>", "files" },
        s = { "<cmd>lua fn.show_string_search_picker()<CR>", "strings" },
        t = { "<cmd>TodoTelescope<CR>", "todos" },
      },
      p = {
        name = "packages",
        p = { "<cmd>PackerSync<CR>", "sync packages" },
      },
      q = {
        name = "quickfix",
        q = { "<cmd>lua fn.toggle_quickfix()<CR>", "show" },
        n = { "<cmd>cnext<CR>", "next" },
        N = { "<cmd>cprev<CR>", "previous" },
      },
      t = { "<cmd>NvimTreeToggle<CR>", "tree" },
      w = { "<cmd>lua fn.choose_window()<CR>", "window" },
      x = { "<cmd>lua fn.close_buffer()<CR>", "close" },
      z = { "<cmd>only<CR>", "zoom" },
    },
  }, { mode = "n" })
end

return M
