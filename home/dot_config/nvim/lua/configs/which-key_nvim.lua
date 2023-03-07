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
      ["`"] = { "<cmd>lua fn.open_terminal()<CR>", "terminal" },
      g = {
        name = "git",
        b = { "<cmd>Gitsigns blame_line<CR>", "blame" },
        d = { "<cmd>DiffviewOpen<CR>", "diff" },
        g = { fn.open_commit_log, "commits" },
        h = { "<cmd>DiffviewFileHistory<CR>", "history" },
        n = { "<cmd>Gitsigns next_hunk<CR>", "next hunk" },
        N = { "<cmd>Gitsigns prev_hunk<CR>", "prev hunk" },
        p = { "<cmd>Gitsigns preview_hunk<CR>", "preview hunk" },
        r = { ":Gitsigns reset_hunk<CR>", "reset hunk" },
        s = { ":Gitsigns stage_hunk<CR>", "stage hunk" },
      },
      f = {
        name = "file",
        d = { fn.delete_file, "delete" },
        m = { fn.move_file, "move" },
        o = { fn.open_file, "open" },
      },
      l = { name = "LSP" },
      s = { fn.search.prompt, "search string" },
      q = {
        name = "quickfix",
        q = { fn.toggle_quickfix, "toggle" },
        j = { fn.next_quickfix, "next" },
        k = { fn.prev_quickfix, "previous" },
      },
      w = { fn.choose_window, "window" },
      x = { fn.close_buffer, "close" },
      z = { "<cmd>only<CR>", "zoom" },
    },
  }, { mode = "n" })

  require"which-key".register({
    ["<leader>"] = {
      s = { function() fn.search.prompt([[]], vim.fn.expand[[<cword>]]) end, "search string" },
    },
  }, { mode = "x" })
end

return M
