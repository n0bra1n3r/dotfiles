return {
  [""] = {
    ["<Down>"]          = { fn.get_map_expr("<Down>"), expr = true },
    ["<Up>"]            = { fn.get_map_expr("<Up>"), expr = true },
    ["^"]               = { fn.get_map_expr("^"), expr = true },
    ["$"]               = { fn.get_map_expr("$"), expr = true },
    ["0"]               = { fn.get_map_expr("0"), expr = true },
    j                   = { fn.get_map_expr("j"), expr = true },
    k                   = { fn.get_map_expr("k"), expr = true },
  },
  i = {
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
  },
  n = {
    ["<M-l>"]           = { "<C-w>h" },
    ["<M-j>"]           = { "<C-w>j" },
    ["<M-k>"]           = { "<C-w>k" },
    ["<M-;>"]           = { "<C-w>l" },
    ["<C-w><C-f>"]      = { "<cmd>lua fn.edit_file('vsplit', vim.fn.expand('<cfile>'))<CR>" },
    ["<C-w>f"]          = { "<cmd>lua fn.edit_file('split', vim.fn.expand('<cfile>'))<CR>" },
    ["<C-w>gf"]         = { "<cmd>tabe <cfile><CR>" },
    ["<C-Down>"]        = { "<C-w>j" },
    ["<C-Left>"]        = { "<C-w>h" },
    ["<C-Right>"]       = { "<C-w>l" },
    ["<C-Up>"]          = { "<C-w>k" },
    ["<Esc>"]           = { "<cmd>nohlsearch<CR>" },
    ["<End>"]           = { "$", noremap = false },
    ["<Home>"]          = { "^", noremap = false },
    ["<Enter>"]         = { "<cmd>update<CR>:", silent = false },
    ["<F1>"]            = { ":help <C-r><C-w><CR>" },
    ["<Left>"]          = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up>$l':'<Left>'", expr = true },
    ["<PageUp>"]        = { "H<Up>", noremap = false },
    ["<PageDown>"]      = { "L<Down>", noremap = false },
    ["<Space><Space>"]  = { "<C-^>" },
    [";"]               = { "l" },
    gf                  = { "<cmd>lua fn.edit_file('edit', vim.fn.expand('<cfile>'))<CR>" },
    gm                  = { "m" },
    h                   = { ";" },
    l                   = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'", expr = true },
    s                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    S                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    x                   = { "col('$')==col('.')?'gJ':'x'", expr = true },
  },
  t = {
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
  },
  x = {
    ["*"]               = { ":<C-u>let r=getreg('\"')<bar>let t=getregtype('\"')<CR>gvy/<C-r>=&ic?'\\c':'\\C'<CR><C-r><C-r>=substitute(escape(@\",'/\\.*$^~['),'\\_s\\+','\\\\_s\\\\+','g')<CR><CR>gVzv:call setreg('\"',r,t)<CR>" },
    ["#"]               = { ":<C-u>let r=getreg('\"')<bar>let t=getregtype('\"')<CR>gvy?<C-r>=&ic?'\\c':'\\C'<CR><C-r><C-r>=substitute(escape(@\",'?\\.*$^~['),'\\_s\\+','\\\\_s\\\\+','g')<CR><CR>gVzv:call setreg('\"',r,t)<CR>" },
    ["<S-Tab>"]         = { "<gv" },
    ["<Tab>"]           = { ">gv" },
    [";"]               = { "l" },
    h                   = { ";" },
    l                   = { "h" },
    p                   = { "\"_dP" },
    s                   = { "<Plug>Lightspeed_omni_s", noremap = false },
    S                   = { "<Plug>Lightspeed_omni_s", noremap = false },
  },
}
