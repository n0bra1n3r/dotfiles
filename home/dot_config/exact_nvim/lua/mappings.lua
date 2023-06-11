-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function show_buffer_list()
  require'telescope.builtin'.loclist { prompt_title = "Window Buffers" }
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

local function open_float()
  local width = math.min(vim.o.columns * 0.9, vim.o.columns - 16)
  local height = vim.o.lines * 0.9
  require'mini.misc'.zoom(0, {
    border = "single",
    width = vim.fn.ceil(width),
    height = vim.fn.ceil(height),
    row = vim.o.lines / 2 - height / 2 - 1,
    col = vim.o.columns / 2 - width / 2,
  })
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
    ["<LeftMouse>"]     = { "ma<LeftMouse>`a" },
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
    ["<M-\\>"]          = { "<cmd>vsplit<CR>" },
    ["<M-->"]           = { "<cmd>split<CR>" },
    ["<M-=>"]           = { open_float },
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
    ["<C-z>"]           = { fn.open_terminal },
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
    C                   = { '"_C' },
    c                   = { '"_c' },
    d                   = { '"_d' },
    D                   = { '"_D' },
    gf                  = { edit, desc = "Edit file" },
    h                   = { ";" },
    l                   = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'", expr = true },
    x                   = { "col('$')==col('.')?'gJ':'\"_x'", expr = true },
    yD                  = { "D" },
    yd                  = { "dd" },
    yx                  = { "col('$')==col('.')?'gJ':'x'", expr = true },
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
    c                   = { '"_c' },
    d                   = { '"_d' },
    h                   = { ";" },
    l                   = { "h" },
    p                   = { "P" },
    P                   = { "p" },
    y                   = { "ygv" },
  }, --}}}
}
