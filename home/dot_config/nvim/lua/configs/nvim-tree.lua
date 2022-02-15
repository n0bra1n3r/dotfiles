local M = {}

function M.setup()
  vim.g.nvim_tree_group_empty = 1
  vim.g.nvim_tree_highlight_opened_files = 3
  vim.g.nvim_tree_indent_markers = 1
  vim.g.nvim_tree_respect_buf_cwd = 1
end

function edit(node)
  if node.nodes ~= nil then
    require"nvim-tree.lib".expand_or_collapse(node)
  else
    fn.edit_file("edit", node.absolute_path)
  end
end

function vsplit(node)
  if node.nodes ~= nil then
    require"nvim-tree.lib".expand_or_collapse(node)
  else
    fn.edit_file("vsplit", node.absolute_path)
  end
end

function split(node)
  if node.nodes ~= nil then
    require"nvim-tree.lib".expand_or_collapse(node)
  else
    fn.edit_file("split", node.absolute_path)
  end
end

function M.config()
  vim.cmd[[augroup conf_nvimtree]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd BufEnter * if isdirectory(expand("%")) | exec "enew | bw # | NvimTreeOpen" | endif]]
  vim.cmd[[autocmd BufLeave NvimTree NvimTreeClose]]
  vim.cmd[[augroup end]]

  require"nvim-tree".setup {
    actions = {
      change_dir = {
        global = true,
      },
    },
    hijack_cursor = true,
    update_focused_file = {
      enable = true,
      update_cwd = true,
    },
    update_cwd = true,
    update_to_buf_dir = {
      enable = false,
    },
    view = {
      auto_close = true,
      auto_resize = true,
      hide_root_folder = true,
      mappings = {
        list = {
          { key = { "<CR>", "<Left>", "l" } , action = "edit", action_cb = edit },
          { key = { "<Right>", "|", ";" }   , action = "vsplit", action_cb = vsplit },
          { key = "_"                       , action = "split", action_cb = split },
          { key = "o"                       , action = "create" },
          { key = { "<BS>", "<Del>", "D" }  , action = "remove" },
          { key = "d"                       , action = "cut" },
          { key = "y"                       , action = "copy" },
          { key = "p"                       , action = "paste" },
          { key = "i"                       , action = "rename" },
          { key = "Y"                       , action = "copy_path" },
          { key = "<ESC>"                   , action = "close" },
        },
      },
      side = "right",
      width = 32,
    },
  }
end

return M
