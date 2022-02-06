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
        b = { "<cmd>lua fn.debug_break()<CR>", "break execution" },
        c = { "<cmd>lua fn.debug_continue()<CR>", "debug continue" },
        d = { "<cmd>lua fn.debug_step()<CR>", "debug step" },
        s = { "<cmd>lua fn.debug_show_symbol()<CR>", "show symbol" },
        S = { "<cmd>lua fn.debug_show_symbols()<CR>", "show symbols" },
        x = { "<cmd>lua fn.debug_exit()<CR>", "exit session" }
      },
      r = {
        name = "runner",
        b = { "<cmd>AsyncTask project-build<CR>", "build project" },
        d = {
          name = "debug project",
          b = { "<cmd>lua fn.debug_project()<CR>", "break execution" },
          c = { "<cmd>lua fn.debug_project_continue()<CR>", "debug continue" },
          d = { "<cmd>lua fn.debug_project_step()<CR>", "debug step" },
        },
        r = { "<cmd>AsyncTask project-run<CR>", "run project" },
        s = { "<cmd>lua fn.open_run_shell()<CR>", "open shell" },
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
      w = { "<cmd>wa<CR>", "write" },
      x = { "<cmd>lua fn.close_buffer()<CR>", "close" },
      X = { "<cmd>qa<CR>", "exit" },
      z = { "<cmd>only<CR>", "zoom" },
    },
  }, { mode = "n" })
end

return M
