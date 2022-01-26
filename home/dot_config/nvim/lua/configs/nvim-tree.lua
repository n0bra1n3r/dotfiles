local M = {}

function M.setup()
  vim.g.nvim_tree_group_empty = 1
  vim.g.nvim_tree_highlight_opened_files = 1
  vim.g.nvim_tree_indent_markers = 1
  vim.g.nvim_tree_respect_buf_cwd = 1
end

M.config = function()
  vim.cmd[[autocmd! BufLeave NvimTree NvimTreeClose]]

  require"nvim-tree".setup {
    hijack_cursor = true,
    update_focused_file = {
      enable = true,
      update_cwd = true,
    },
    update_cwd = true,
    view = {
      auto_resize = true,
      hide_root_folder = true,
      mappings = {
        custom_only = true,
        list = {
          { key = { "<CR>", "<Left>" }    , cb = require"nvim-tree.config".nvim_tree_callback("edit") },
          { key = { "<Right>", "|" }      , cb = require"nvim-tree.config".nvim_tree_callback("vsplit") },
          { key = "_"                     , cb = require"nvim-tree.config".nvim_tree_callback("split") },
          { key = "o"                     , cb = require"nvim-tree.config".nvim_tree_callback("create") },
          { key = { "<BS>", "<Del>", "D" }, cb = require"nvim-tree.config".nvim_tree_callback("remove") },
          { key = "d"                     , cb = require"nvim-tree.config".nvim_tree_callback("cut") },
          { key = "y"                     , cb = require"nvim-tree.config".nvim_tree_callback("copy") },
          { key = "p"                     , cb = require"nvim-tree.config".nvim_tree_callback("paste") },
          { key = "i"                     , cb = require"nvim-tree.config".nvim_tree_callback("rename") },
          { key = "Y"                     , cb = require"nvim-tree.config".nvim_tree_callback("copy_path") },
          { key = "<ESC>"                 , cb = require"nvim-tree.config".nvim_tree_callback("close") },
        },
      },
      side = "right",
    },
  }
end

return M
