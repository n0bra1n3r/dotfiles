local M = {}

function M.config()
  require"which-key".setup {
    window = {
      border = "single",
      margin = { 0, 0, 0, 0 },
      padding = { 0, 0, 0, 0 },
      position = "top",
    },
    triggers_blacklist = {
      i = { "j", "k" },
      n = { "d", "y" },
      v = { "j", "k" },
    },
  }
  require"which-key".register({
    ["<leader>"] = {
      ["`"] = { "<cmd>lua fn.open_shell()<CR>", "shell" },
      b = { "<cmd>lua require'telescope.builtin'.buffers{ sort_lastused = true }<CR>", "buffers" },
      g = {
        name = "git",
        b = { "<cmd>Gitsigns blame_line<CR>", "blame" },
        d = { "<cmd>DiffviewOpen<CR>", "diff" },
        h = { "<cmd>DiffviewFileHistory<CR>", "history" },
        n = { "<cmd>Gitsigns next_hunk<CR>", "next hunk" },
        N = { "<cmd>Gitsigns prev_hunk<CR>", "prev hunk" },
        p = { "<cmd>Gitsigns preview_hunk<CR>", "preview hunk" },
        r = { ":Gitsigns reset_hunk<CR>", "reset hunk" },
        s = { ":Gitsigns stage_hunk<CR>", "stage hunk" },
      },
      f = {
        name = "file",
        d = { "<cmd>lua fn.delete_file()<CR>", "delete" },
        m = { "<cmd>lua fn.move_file()<CR>", "move" },
        o = { "<cmd>lua fn.open_file()<CR>", "open" },
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
      l = { name = "LSP" },
      r = {
        name = "runner",
        b = { "<cmd>lua fn.project_build()<CR>", "build" },
        d = { "<cmd>lua fn.project_build_and_debug()<CR>", "build and debug" },
        r = { "<cmd>lua fn.project_build_and_run()<CR>", "build and run" },
        R = { "<cmd>lua fn.project_run()<CR>", "run" },
        s = { "<cmd>lua fn.open_run_shell()<CR>", "shell" },
        t = { "<cmd>lua fn.project_test()<CR>", "test" },
      },
      P = { "paste unformatted before" },
      p = { "paste unformatted after" },
      s = { "<cmd>lua require'search'.prompt()<CR>", "search string" },
      t = { "<cmd>lua fn.open_file_tree()<CR>", "file tree" },
      q = {
        name = "quickfix",
        q = { "<cmd>lua fn.toggle_quickfix()<CR>", "show" },
        n = { "<cmd>exec 'lua fn.open_quickfix()' | cnext<CR>", "next" },
        N = { "<cmd>exec 'lua fn.open_quickfix()' | cprev<CR>", "previous" },
      },
      w = { "<cmd>lua fn.choose_window()<CR>", "window" },
      x = { "<cmd>lua fn.close_buffer()<CR>", "close" },
      z = { "<cmd>only<CR>", "zoom" },
    },
  }, { mode = "n" })

  require"which-key".register({
    ["<leader>"] = {
      s = {
        name = "search",
        s = { "<cmd>lua require'search'.prompt([[]], vim.fn.expand[[<cword>]])<CR>", "strings" },
      },
    },
  }, { mode = "x" })
end

return M
