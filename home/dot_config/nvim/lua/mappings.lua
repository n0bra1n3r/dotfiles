return {
  [""] = {
    ["<Down>"]      = { fn.get_map_expr("<Down>")       , noremap = true, expr = true },
    ["<Up>"]        = { fn.get_map_expr("<Up>")         , noremap = true, expr = true },
    ["^"]           = { fn.get_map_expr("^")            , noremap = true, expr = true },
    ["$"]           = { fn.get_map_expr("$")            , noremap = true, expr = true },
    ["0"]           = { fn.get_map_expr("0")            , noremap = true, expr = true },
    j               = { fn.get_map_expr("j")            , noremap = true, expr = true },
    k               = { fn.get_map_expr("k")            , noremap = true, expr = true },
  },
  i = {
    ["<End>"]       = { "<C-o>$" },
    ["<Home>"]      = { "<C-o>^" },
    ["<Insert>"]    = { "<Esc>"                         , noremap = true },
    ["<PageUp>"]    = { "<Esc>H<Up>" },
    ["<PageDown>"]  = { "<Esc>L<Down>" },
    ["<S-Tab>"]     = { "<C-d>"                         , noremap = true },
    ["<Down>"]      = { "<Esc><Down>" },
    ["<Left>"]      = { "<Esc><Left>" },
    ["<Right>"]     = { "<Right><Esc><Right>" },
    ["<Up>"]        = { "<Esc><Up>" },
  },
  n = {
    ["<C-h>"]       = { "<C-w>h"                        , noremap = true },
    ["<C-j>"]       = { "<C-w>j"                        , noremap = true },
    ["<C-k>"]       = { "<C-w>k"                        , noremap = true },
    ["<C-l>"]       = { "<C-w>l"                        , noremap = true },
    ["<C-Down>"]    = { "<C-w>j"                        , noremap = true },
    ["<C-Left>"]    = { "<C-w>h"                        , noremap = true },
    ["<C-Right>"]   = { "<C-w>l"                        , noremap = true },
    ["<C-Up>"]      = { "<C-w>k"                        , noremap = true },
    ["<End>"]       = { "$" },
    ["<Home>"]      = { "^" },
    ["<Enter>"]     = { ":"                             , noremap = true },
    ["<Esc>"]       = { ":nohlsearch<CR><Esc>"          , noremap = true, silent = true },
    ["<F1>"]        = { ":help <C-r><C-w><CR>"          , noremap = true, silent = true },
    ["<Left>"]      = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up>$l':'<Left>'"
                                                        , noremap = true, expr = true },
    ["<PageUp>"]    = { "H<Up>" },
    ["<PageDown>"]  = { "L<Down>" },
    ["<Tab>"]       = { "<cmd>lua fn.next_buffer()<CR>" , noremap = true, silent = true },
    ["<S-Tab>"]     = { "<cmd>lua fn.prev_buffer()<CR>" , noremap = true, silent = true },
    [";"]           = { "l"                             , noremap = true },
    h               = { ";"                             , noremap = true },
    l               = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'"
                                                        , noremap = true, expr = true },
    x               = { "col('$')==col('.')?'gJ':'x'"   , noremap = true, expr = true },
  },
  t = {
    ["<Esc>"]       = { "<C-\\><C-n>"                   , noremap = true },
  },
  v = {
    ["*"]           = { ":<C-u>let r=getreg('\"')<bar>let t=getregtype('\"')<CR>gvy/<C-r>=&ic?'\\c':'\\C'<CR><C-r><C-r>=substitute(escape(@\",'/\\.*$^~['),'\\_s\\+','\\\\_s\\\\+','g')<CR><CR>gVzv:call setreg('\"',r,t)<CR>"
                                                        , noremap = true, silent = true },
    ["#"]           = { ":<C-u>let r=getreg('\"')<bar>let t=getregtype('\"')<CR>gvy?<C-r>=&ic?'\\c':'\\C'<CR><C-r><C-r>=substitute(escape(@\",'?\\.*$^~['),'\\_s\\+','\\\\_s\\\\+','g')<CR><CR>gVzv:call setreg('\"',r,t)<CR>"
                                                        , noremap = true, silent = true },
    ["<S-Tab>"]     = { "<gv"                           , noremap = true },
    ["<Tab>"]       = { ">gv"                           , noremap = true },
    [";"]           = { "l"                             , noremap = true },
    h               = { ";"                             , noremap = true },
    l               = { "h"                             , noremap = true },
    p               = { "\"_dP"                         , noremap = true },
  },
}
