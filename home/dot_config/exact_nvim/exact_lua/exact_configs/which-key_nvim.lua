-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function show_commits()
  require'telescope.builtin'.git_commits()
end

local function search_and_replace()
  require'search'.prompt()
end

local function search_and_replace_selection()
  require'search'.prompt([[]], vim.fn.expand[[<cword>]])
end
--}}}

function plug.config()
  require'which-key'.setup {
    window = {
      border = "single",
      margin = { 0, 0, 0, 0 },
      padding = { 0, 0, 0, 0 },
      position = "top",
    },
  }
  require'which-key'.register({
    ["<leader>"] = {
      a = {
        name = "AI",
        i = { "<cmd>ChatGPT<CR>", "Chat" },
      },
      d = { fn.resume_debugging, "Debug" },
      g = {
        name = "Git",
        b = { "<cmd>Gitsigns blame_line<CR>", "Blame" },
        c = { show_commits, "commits" },
        n = { "<cmd>Gitsigns next_hunk<CR>", "Next hunk" },
        N = { "<cmd>Gitsigns prev_hunk<CR>", "Prev hunk" },
        p = { "<cmd>Gitsigns preview_hunk<CR>", "Preview hunk" },
        r = { ":Gitsigns reset_hunk<CR>", "Reset hunk" },
        s = { ":Gitsigns stage_hunk<CR>", "Stage hunk" },
      },
      f = {
        name = "File",
        d = { fn.delete_file, "Delete" },
        e = { fn.edit_file, "Edit" },
        m = { fn.move_file, "Move" },
        o = { fn.open_file_folder, "Open folder" },
      },
      i = { "<cmd>Telescope diagnostics<CR>", "Issues" },
      p = {
        name = "packages",
        a = { "<cmd>Mason<CR>", "Packages" },
        l = { "<cmd>Lazy<CR>", "Plugins" },
      },
      s = { search_and_replace, "Search & replace" },
      t = { "<cmd>OverseerRun<CR>", "Tasks" },
      w = { fn.choose_window, "Window" },
      x = { fn.close_buffer, "Close" },
      z = { "<cmd>only<CR>", "Zoom" },
    },
  }, { mode = "n" })
  require'which-key'.register({
    ["<leader>"] = {
      a = {
        name = "AI",
        d = { "<cmd>ChatGPTRun docstring<CR>", "Generate docstring" },
        i = { "<cmd>ChatGPT<CR>", "Chat" },
        t = { "<cmd>ChatGPTRun add_tests<CR>", "Generate tests" },
      },
      s = { search_and_replace_selection, "Search & replace" },
    },
  }, { mode = "x" })
end
