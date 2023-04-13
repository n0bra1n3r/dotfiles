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

  c = { --{{{
    ["<Enter>"]         = { "getcmdline()==''?'update<CR>':'<CR>'", expr = true }
  }, --}}}

  i = { --{{{
    ["<End>"]           = { "<C-o>$", noremap = false },
    ["<Home>"]          = { "<C-o>^", noremap = false },
    ["<Insert>"]        = { "<Esc>" },
    ["<M-;>"]           = { "<C-o>l" },
    ["<M-j>"]           = { "<C-o>j" },
    ["<M-k>"]           = { "<C-o>k" },
    ["<M-l>"]           = { "<C-o>h" },
    ["<PageUp>"]        = { "<Esc>H<Up>", noremap = false },
    ["<PageDown>"]      = { "<Esc>L<Down>", noremap = false },
    ["<S-Tab>"]         = { "<C-d>" },
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
    ["<C-Tab>"]         = { require'telescope.builtin'.buffers, desc = "buffer list" },
    ["<Esc>"]           = { ":nohlsearch<CR>" },
    ["<End>"]           = { "$", noremap = false },
    ["<Home>"]          = { "^", noremap = false },
    ["<Enter>"]         = { ":", silent = false },
    ["<F1>"]            = { ":help <C-r><C-w><CR>" },
    ["<Left>"]          = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up>$l':'<Left>'", expr = true },
    ["<PageUp>"]        = { "H<Up>", noremap = false },
    ["<PageDown>"]      = { "L<Down>", noremap = false },
    ["<Space><Space>"]  = { require'telescope.builtin'.find_files, desc = "file tree" },
    [";"]               = { "l" },
    gf                  = { function() fn.edit_file("edit", vim.fn.expand("<cfile>")) end },
    h                   = { ";" },
    l                   = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'", expr = true },
    mm                  = { "dd" },
    M                   = { "D" },
    s                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    S                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    x                   = { "col('$')==col('.')?'gJ':'\"_x'", expr = true },
    zQ                  = { "foldclosed('.')!=-1?'zMzO[z':'zM'", expr = true, desc = "Open fold under cursor and close all others" },
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
    ["<M-;>"]           = { "<C-\\><C-n>l" },
    ["<M-j>"]           = { "<C-\\><C-n>j" },
    ["<M-k>"]           = { "<C-\\><C-n>k" },
    ["<M-l>"]           = { "<C-\\><C-n>h" },
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
