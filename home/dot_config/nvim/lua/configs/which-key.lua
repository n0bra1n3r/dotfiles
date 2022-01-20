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
      ["`"] = { "<cmd>lua fn.open_git_shell()<CR>", "shell" },
      b = { "<cmd>BufferLinePick<CR>", "buffer" },
      s = {
        name = "search",
        b = { "<cmd>Telescope buffers<CR>", "search buffers" },
        f = { "<cmd>Telescope find_files<CR>", "search files" },
        s = { "<cmd>lua fn.show_string_search_picker()<CR>", "search strings" },
        t = { "<cmd>TodoTelescope<CR>", "search todos" },
      },
      d = {
        name = "diff",
        d = { "<cmd>DiffviewOpen<CR>", "view diff" },
        h = { "<cmd>DiffviewFileHistory<CR>", "file history" },
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
      w = { "<cmd>wa<CR>", "write" },
      x = { "<cmd>lua fn.close_buffer()<CR>", "close" },
      X = { "<cmd>qa<CR>", "exit" },
      z = { "<cmd>only<CR>", "zoom" },
    },
  }, { mode = "n" })
end

return M
