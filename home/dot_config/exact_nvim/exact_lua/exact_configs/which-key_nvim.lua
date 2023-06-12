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
      d = { fn.resume_debugging, "debug" },
      g = {
        name = "git",
        b = { "<cmd>Gitsigns blame_line<CR>", "blame" },
        c = { show_commits, "commits" },
        n = { "<cmd>Gitsigns next_hunk<CR>", "next hunk" },
        N = { "<cmd>Gitsigns prev_hunk<CR>", "prev hunk" },
        p = { "<cmd>Gitsigns preview_hunk<CR>", "preview hunk" },
        r = { ":Gitsigns reset_hunk<CR>", "reset hunk" },
        s = { ":Gitsigns stage_hunk<CR>", "stage hunk" },
      },
      f = {
        name = "file",
        d = { fn.delete_file, "delete" },
        e = { fn.edit_file, "edit" },
        m = { fn.move_file, "move" },
        o = { fn.open_file_folder, "open folder" },
      },
      p = {
        name = "packages",
        a = { "<cmd>Mason<CR>", "packages" },
        l = { "<cmd>Lazy<CR>", "plugins" },
      },
      s = { search_and_replace, "search & replace" },
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
  require'which-key'.register({
    ["<leader>"] = {
      s = { search_and_replace_selection, "search & replace" },
    },
  }, { mode = "x" })
end
