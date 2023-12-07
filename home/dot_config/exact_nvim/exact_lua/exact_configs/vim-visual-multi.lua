return {
  init = function()
    vim.g.VM_maps = {
      ["Add Cursor Down"] = [[<C-j>]],
      ["Add Cursor Up"] = [[<C-k>]],
    }
    vim.g.VM_custom_motions = {
      [';'] = [[l]],
      h = [[;]],
      l = [[h]],
    }
  end
}
