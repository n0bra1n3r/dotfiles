-- vim: foldmethod=marker foldlevel=0 foldenable

mappings {
  [""] = { --{{{
    ["<Down>"]          = { fn.get_map_expr("<Down>"), expr = true },
    ["<Up>"]            = { fn.get_map_expr("<Up>"), expr = true },
    ["^"]               = { fn.get_map_expr("^"), expr = true },
    ["$"]               = { fn.get_map_expr("$"), expr = true },
    ["0"]               = { fn.get_map_expr("0"), expr = true },
    j                   = { fn.get_map_expr("j"), expr = true },
    k                   = { fn.get_map_expr("k"), expr = true },
  }, --}}}

  i = { --{{{
    ["<End>"]           = { "<C-o>$", noremap = false },
    ["<Home>"]          = { "<C-o>^", noremap = false },
    ["<Insert>"]        = { "<Esc>" },
    ["<PageUp>"]        = { "<Esc>H<Up>", noremap = false },
    ["<PageDown>"]      = { "<Esc>L<Down>", noremap = false },
    ["<S-Tab>"]         = { "<C-d>" },
    ["<Down>"]          = { "<Esc><Down>", noremap = false },
    ["<Left>"]          = { "<Esc><Left>", noremap = false },
    ["<Right>"]         = { "<Right><Esc><Right>", noremap = false },
    ["<Up>"]            = { "<Esc><Up>", noremap = false },
  }, --}}}

  n = { --{{{
    ["<M-;>"]           = { "<C-w>l" },
    ["<M-j>"]           = { "<C-w>j" },
    ["<M-k>"]           = { "<C-w>k" },
    ["<M-l>"]           = { "<C-w>h" },
    ["<C-w><C-f>"]      = { function() fn.edit_file("vsplit", vim.fn.expand("<cfile>")) end },
    ["<C-w>f"]          = { function() fn.edit_file("split", vim.fn.expand("<cfile>")) end },
    ["<C-w>gf"]         = { "<cmd>tabe <cfile><CR>" },
    ["<C-Down>"]        = { "<C-w>j" },
    ["<C-Left>"]        = { "<C-w>h" },
    ["<C-Right>"]       = { "<C-w>l" },
    ["<C-Up>"]          = { "<C-w>k" },
    ["<C-Tab>"]         = { function() require"telescope.builtin".buffers{ sort_mru = true, ignore_current_buffer = true } end },
    ["<Esc>"]           = { ":nohlsearch<CR>" },
    ["<End>"]           = { "$", noremap = false },
    ["<Home>"]          = { "^", noremap = false },
    ["<Enter>"]         = { "<cmd>update<CR>" },
    ["<F1>"]            = { ":help <C-r><C-w><CR>" },
    ["<Left>"]          = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up>$l':'<Left>'", expr = true },
    ["<PageUp>"]        = { "H<Up>", noremap = false },
    ["<PageDown>"]      = { "L<Down>", noremap = false },
    ["<Space><Space>"]  = { fn.open_file_tree, desc = "file tree" },
    ["<Tab>"]           = { "foldclosed('.')!=-1?'zMzO[z':'zM'", expr = true },
    [";"]               = { "l" },
    gf                  = { function() fn.edit_file("edit", vim.fn.expand("<cfile>")) end },
    h                   = { ";" },
    l                   = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'", expr = true },
    mm                  = { "dd" },
    M                   = { "D" },
    s                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    S                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    x                   = { "col('$')==col('.')?'gJ':'\"_x'", expr = true },
  }, --}}}

  t = { --{{{
    ["<C-h>"]           = { "<C-\\><C-n><C-w>h" },
    ["<C-j>"]           = { "<C-\\><C-n><C-w>j" },
    ["<C-k>"]           = { "<C-\\><C-n><C-w>k" },
    ["<C-l>"]           = { "<C-\\><C-n><C-w>l" },
    ["<C-Down>"]        = { "<C-\\><C-n><C-w>j" },
    ["<C-Left>"]        = { "<C-\\><C-n><C-w>h" },
    ["<C-Right>"]       = { "<C-\\><C-n><C-w>l" },
    ["<C-Up>"]          = { "<C-\\><C-n><C-w>k" },
    ["<Esc>"]           = { "<C-\\><C-n>" },
    ["<PageUp>"]        = { "<C-\\><C-n>H<Up>" },
    ["<PageDown>"]      = { "<C-\\><C-n>L<Down>" },
  }, --}}}

  x = { --{{{
    ["<S-Tab>"]         = { "<gv" },
    ["<Tab>"]           = { ">gv" },
    [";"]               = { "l" },
    h                   = { ";" },
    l                   = { "h" },
    m                   = { "d" },
    p                   = { "\"_dP" },
    s                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    S                   = { "<Plug>Lightspeed_omni_s", noremap = false },
  }, --}}}
}
