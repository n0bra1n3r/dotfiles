-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function show_buffer_list()
  require'telescope.builtin'.buffers()
end

local function show_file_list()
  require'telescope.builtin'.find_files()
end

local function close_all_folds()
  require'ufo'.closeAllFolds()
end

local function open_all_folds()
  require'ufo'.openAllFolds()
end

local function edit_in_vert_split()
  fn.edit_buffer("vsplit", vim.fn.expand("<cfile>"))
end

local function edit_in_split()
  fn.edit_buffer("split", vim.fn.expand("<cfile>"))
end

local function edit()
  fn.edit_buffer("edit", vim.fn.expand("<cfile>"))
end
--}}}

my_mappings {
  [""] = { --{{{ normal mode, visual mode, operator pending mode
    ["<Down>"]          = { fn.get_map_expr("<Down>"), expr = true },
    ["<Up>"]            = { fn.get_map_expr("<Up>"), expr = true },
    ["^"]               = { fn.get_map_expr("^"), expr = true },
    ["$"]               = { fn.get_map_expr("$"), expr = true },
    ["0"]               = { fn.get_map_expr("0"), expr = true },
    j                   = { fn.get_map_expr("j"), expr = true },
    k                   = { fn.get_map_expr("k"), expr = true },
  }, --}}}
  i = { --{{{
    ["<Down>"]          = { fn.get_map_expr_i("<Down>"), expr = true },
    ["<End>"]           = { "<C-o>$", noremap = false },
    ["<Home>"]          = { "<C-o>^", noremap = false },
    ["<Insert>"]        = { "<Esc>" },
    ["<M-;>"]           = { "<Right>" },
    ["<M-j>"]           = { "'<C-o>'."..fn.get_map_expr("<Down>"), expr = true },
    ["<M-k>"]           = { "'<C-o>'."..fn.get_map_expr("<Up>"), expr = true },
    ["<M-l>"]           = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up><End>':'<Left>'", expr = true },
    ["<PageUp>"]        = { "<Esc>H<Up>", noremap = false },
    ["<PageDown>"]      = { "<Esc>L<Down>", noremap = false },
    ["<S-Tab>"]         = { "<C-d>" },
    ["<Up>"]            = { fn.get_map_expr_i("<Up>"), expr = true },
  }, --}}}
  n = { --{{{
    ["<M-`>"]           = { fn.toggle_terminal },
    ["<M-1>"]           = { fn.execute_last_terminal_command },
    ["<M-;>"]           = { "<C-w>l" },
    ["<M-j>"]           = { "<C-w>j" },
    ["<M-k>"]           = { "<C-w>k" },
    ["<M-l>"]           = { "<C-w>h" },
    ["<C-c>"]           = { "<cmd>tabclose<CR>" },
    ["<C-w><C-f>"]      = { edit_in_vert_split, desc = "Edit file in vertical split" },
    ["<C-w>f"]          = { edit_in_split, desc = "Edit file in split" },
    ["<C-w>gf"]         = { "<cmd>tabe <cfile><CR>", desc = "Edit file in tab" },
    ["<C-Down>"]        = { "<C-w>j" },
    ["<C-Left>"]        = { "<C-w>h" },
    ["<C-Right>"]       = { "<C-w>l" },
    ["<C-Up>"]          = { "<C-w>k" },
    ["<C-Tab>"]         = { show_buffer_list },
    ["<Esc>"]           = { ":nohlsearch<CR>" },
    ["<End>"]           = { "$", noremap = false },
    ["<Home>"]          = { "^", noremap = false },
    ["<Enter>"]         = { fn.save_file, silent = false },
    ["<F1>"]            = { fn.open_help },
    ["<Left>"]          = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up><End><Right>':'<Left>'", expr = true },
    ["<PageUp>"]        = { "H<Up>", noremap = false },
    ["<PageDown>"]      = { "L<Down>", noremap = false },
    ["<Space><Space>"]  = { show_file_list, desc = "Files" },
    [";"]               = { "l" },
    d                   = { '"_d' },
    gf                  = { edit, desc = "Edit file" },
    h                   = { ";" },
    l                   = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'", expr = true },
    x                   = { "col('$')==col('.')?'gJ':'\"_x'", expr = true },
    yd                  = { "dd" },
    zM                  = { close_all_folds },
    zR                  = { open_all_folds },
    zq                  = { "foldclosed('.')!=-1?'zMzO[z':'zM'", expr = true, noremap = false, desc = "Open fold under cursor and close all others" },
  }, --}}}
  t = { --{{{
    ["<C-;>"]           = { "<End>" },
    ["<C-l>"]           = { "<Home>" },
    ["<C-Left>"]        = { "<Home>" },
    ["<C-Right>"]       = { "<End>" },
    ["<Esc>"]           = { "<C-\\><C-n>" },
    ["<M-`>"]           = { fn.toggle_terminal },
    ["<M-1>"]           = { fn.execute_last_terminal_command },
    ["<M-;>"]           = { "<Right>" },
    ["<M-j>"]           = { "<C-\\><C-n>j" },
    ["<M-k>"]           = { "<C-\\><C-n>k" },
    ["<M-l>"]           = { "<Left>" },
    ["<PageUp>"]        = { "<C-\\><C-n>H<Up>" },
    ["<PageDown>"]      = { "<C-\\><C-n>L<Down>" },
  }, --}}}
  x = { --{{{
    ["<S-Tab>"]         = { "<gv" },
    ["<Tab>"]           = { ">gv" },
    [";"]               = { "l" },
    d                   = { '"_d' },
    D                   = { "d" },
    h                   = { ";" },
    l                   = { "h" },
  }, --}}}
}
