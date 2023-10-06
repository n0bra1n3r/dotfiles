-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function edit_in_split()
  fn.edit_buffer("split", vim.fn.expand("<cfile>"))
end

local function edit_in_vert_split()
  fn.edit_buffer("vsplit", vim.fn.expand("<cfile>"))
end

local function edit_in_buf()
  fn.edit_buffer("edit", vim.fn.expand("<cfile>"))
end

local function execute_last_terminal_command()
  fn.send_terminal("!!", true)
end

local function get_map_expr(key)
  return ("(v:count!=0||mode(1)[0:1]=='no'?'%s':'g%s')"):format(key, key)
end

local function get_map_expr_i(key)
  return ("(v:count!=0||mode(1)[0:1]=='no'?'%s':'<C-o>g%s')"):format(key, key)
end

local function open_file_in_github()
  fn.open_in_github()
end

local function search_and_replace()
  require'search'.prompt()
end

local function show_buffer_list()
  require'telescope.builtin'.loclist { prompt_title = "Window Buffers" }
end

local function show_commits()
  require'telescope.builtin'.git_commits()
end

local function show_backward_jumps()
  fn.show_buffer_jump_picker[[backward]]
end

local function show_forward_jumps()
  fn.show_buffer_jump_picker[[forward]]
end

local function goto_bookmark(tag)
  return function()
    fn.goto_bookmark(tag)
  end
end

local function del_cur_bookmark()
  fn.del_bookmark()
end

local function update_file()
  if fn.is_empty_buffer() then
    fn.save_file()
  else
    vim.cmd[[silent update]]
  end
end
--}}}

my_mappings {
  [""] = { --{{{ normal mode, visual mode, operator pending mode
    ["<Down>"]          = { get_map_expr("<Down>"), expr = true },
    ["<Up>"]            = { get_map_expr("<Up>"), expr = true },
    ["^"]               = { get_map_expr("^"), expr = true },
    ["$"]               = { get_map_expr("$"), expr = true },
    ["0"]               = { get_map_expr("0"), expr = true },
    j                   = { get_map_expr("j"), expr = true },
    k                   = { get_map_expr("k"), expr = true },
  }, --}}}
  i = { --{{{
    ["<Down>"]          = { get_map_expr_i("<Down>"), expr = true },
    ["<End>"]           = { "<C-o>$", noremap = false },
    ["<Home>"]          = { "<C-o>^", noremap = false },
    ["<Insert>"]        = { "<Esc>" },
    ["<M-;>"]           = { "<Right>" },
    ["<M-j>"]           = { "'<C-o>'."..get_map_expr("<Down>"), expr = true },
    ["<M-k>"]           = { "'<C-o>'."..get_map_expr("<Up>"), expr = true },
    ["<M-l>"]           = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up><End>':'<Left>'", expr = true },
    ["<PageDown>"]      = { "<Esc>L<Down>", noremap = false },
    ["<PageUp>"]        = { "<Esc>H<Up>", noremap = false },
    ["<S-Tab>"]         = { "<C-d>" },
    ["<Up>"]            = { get_map_expr_i("<Up>"), expr = true },
  }, --}}}
  c = { --{{{
    ["<M-;>"]           = { "<Right>", silent = false },
    ["<M-j>"]           = { "<Down>", silent = false },
    ["<M-k>"]           = { "<Up>", silent = false },
    ["<M-l>"]           = { "<Left>", silent = false },
  }, --}}}
  n = { --{{{
    ["<C-`>"]           = { fn.toggle_terminal },
    ["<C-c>"]           = { "<cmd>tabclose<CR>" },
    ["<C-Down>"]        = { "<C-w>j" },
    ["<C-i>"]           = { show_backward_jumps },
    ["<C-Left>"]        = { "<C-w>h" },
    ["<C-o>"]           = { show_forward_jumps },
    ["<C-Right>"]       = { "<C-w>l" },
    ["<C-Tab>"]         = { show_buffer_list },
    ["<C-Up>"]          = { "<C-w>k" },
    ["<C-w><C-f>"]      = { edit_in_vert_split, desc = "Edit in vert split" },
    ["<C-w>f"]          = { edit_in_split, desc = "Edit in split" },
    ["<C-w>gf"]         = { "<cmd>tabe <cfile><CR>", desc = "Edit in tab" },
    ["<C-z>"]           = { fn.open_terminal },
    ["<End>"]           = { "$", noremap = false },
    ["<Enter>"]         = { update_file, silent = false },
    ["<Esc>"]           = { ":nohlsearch<CR>" },
    ["<F1>"]            = { ":lua fn.ui_try(vim.cmd.help, vim.fn.expand('<cword>'))<CR>" },
    ["<Home>"]          = { "^", noremap = false },
    ["<Left>"]          = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up><End><Right>':'<Left>'", expr = true },
    ["<leader><Space>"] = { fn.open_explorer, desc = "Explorer" },
    ["<leader>ac"]      = { "<cmd>ChatGPT<CR>", desc = "Chat" },
    ["<leader>d"]       = { fn.resume_debugging, desc = "Debug" },
    ["<leader>fd"]      = { fn.delete_file, desc = "Delete" },
    ["<leader>fe"]      = { fn.edit_file, desc = "Edit" },
    ["<leader>fm"]      = { fn.move_file, desc = "Move" },
    ["<leader>fo"]      = { fn.open_file_folder, desc = "Open folder" },
    ["<leader>fs"]      = { fn.save_file, desc = "Save" },
    ["<leader>gb"]      = { "<cmd>Gitsigns blame_line<CR>", desc = "Blame" },
    ["<leader>gc"]      = { show_commits, desc = "Commits" },
    ["<leader>gg"]      = { fn.open_git_repo, desc = "Open repo" },
    ["<leader>gN"]      = { "<cmd>Gitsigns prev_hunk<CR>", desc = "Prev hunk" },
    ["<leader>gn"]      = { "<cmd>Gitsigns next_hunk<CR>", desc = "Next hunk" },
    ["<leader>gp"]      = { "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview hunk" },
    ["<leader>go"]      = { open_file_in_github, desc = "Open in Github" },
    ["<leader>gr"]      = { ":Gitsigns reset_hunk<CR>", desc = "Reset hunk" },
    ["<leader>gs"]      = { ":Gitsigns stage_hunk<CR>", desc = "Stage hunk" },
    ["<leader>id"]      = { "<cmd>Telescope diagnostics bufnr=0<CR>", desc = "Document issues" },
    ["<leader>iw"]      = { "<cmd>Telescope diagnostics<CR>", desc = "Workspace issues" },
    ["<leader>l"]       = { "<cmd>Telescope lsp_document_symbols<CR>", desc = "LSP symbols" },
    ["<leader>pa"]      = { "<cmd>Mason<CR>", desc = "Packages" },
    ["<leader>pl"]      = { "<cmd>Lazy<CR>", desc = "Plugins" },
    ["<leader>q"]       = { '<cmd>quitall<CR>', desc = "Quit" },
    ["<leader>s"]       = { search_and_replace, desc = "Search & replace" },
    ["<leader>t"]       = { "<cmd>OverseerRun<CR>", desc = "Tasks" },
    ["<leader>w"]       = { fn.choose_window, desc = "Switch window" },
    ["<leader>x"]       = { fn.close_buffer, desc = "Close" },
    ["<leader>z"]       = { "<cmd>only<CR>", desc = "Zoom" },
    ["<M-\\>"]          = { "<cmd>vsplit<CR>" },
    ["<M-->"]           = { "<cmd>split<CR>" },
    ["<M-=>"]           = { fn.float_window },
    ["<M-;>"]           = { "v:lua.fn.is_floating()?'l':'<C-w>l'", expr = true },
    ["<M-1>"]           = { execute_last_terminal_command },
    ["<M-j>"]           = { "v:lua.fn.is_floating()?'j':'<C-w>j'", expr = true },
    ["<M-k>"]           = { "v:lua.fn.is_floating()?'k':'<C-w>k'", expr = true },
    ["<M-l>"]           = { "v:lua.fn.is_floating()?'h':'<C-w>h'", expr = true },
    ["<PageDown>"]      = { "L<Down>", noremap = false },
    ["<PageUp>"]        = { "H<Up>", noremap = false },
    ["<Tab>1"]          = { goto_bookmark(1), desc = "Bookmark 1" },
    ["<Tab>2"]          = { goto_bookmark(2), desc = "Bookmark 2" },
    ["<Tab>3"]          = { goto_bookmark(3), desc = "Bookmark 3" },
    ["<Tab>4"]          = { goto_bookmark(4), desc = "Bookmark 4" },
    ["<Tab>5"]          = { goto_bookmark(5), desc = "Bookmark 5" },
    ["<Tab><BS>"]       = { del_cur_bookmark, desc = "Delete bookmark" },
    [";"]               = { "l" },
    C                   = { '"_C' },
    c                   = { '"_c' },
    D                   = { '"_D' },
    d                   = { '"_d' },
    gf                  = { edit_in_buf, desc = "Edit" },
    h                   = { ";" },
    l                   = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'", expr = true },
    x                   = { "col('$')==col('.')?'gJ':'\"_x'", expr = true },
    yD                  = { 'D', desc = "Cut text after cursor" },
    yd                  = { 'dd', desc = "Cut line" },
    yx                  = { "col('$')==col('.')?'gJ':'x'", expr = true, desc = "Cut character under cursor" },
    zq                  = { "foldclosed('.')!=-1?'zMzO[z':'zM'", expr = true, noremap = false, desc = "Toggle all folds" },
  }, --}}}
  t = { --{{{
    ["<C-`>"]           = { fn.toggle_terminal },
    ["<C-;>"]           = { "<End>" },
    ["<C-Left>"]        = { "<Home>" },
    ["<C-l>"]           = { "<Home>" },
    ["<C-Right>"]       = { "<End>" },
    ["<Esc>"]           = { "!v:lua.fn.is_floating()?'<Esc>':'<C-\\><C-n>'", expr = true },
    ["<LeftMouse>"]     = { "<nop>" },
    ["<M-;>"]           = { "<Right>" },
    ["<M-1>"]           = { execute_last_terminal_command },
    ["<M-j>"]           = { "<C-\\><C-n>j" },
    ["<M-k>"]           = { "<C-\\><C-n>k" },
    ["<M-l>"]           = { "<Left>" },
    ["<PageDown>"]      = { "<C-\\><C-n>L<Down>" },
    ["<PageUp>"]        = { "<C-\\><C-n>H<Up>" },
  }, --}}}
  x = { --{{{
    [";"]               = { "l" },
    ["<F1>"]            = { ":<C-u>lua fn.ui_try(vim.cmd.help,fn.get_visual_selection())<CR>" },
    ["<leader>ac"]      = { "<cmd>ChatGPT<CR>", desc = "Chat" },
    ["<leader>ad"]      = { "<cmd>ChatGPTRun docstring<CR>", desc = "Generate docstring" },
    ["<leader>at"]      = { "<cmd>ChatGPTRun add_tests<CR>", desc = "Generate tests" },
    ["<leader>go"]      = { open_file_in_github, desc = "Open in Github" },
    ["<leader>s"]       = { ":<C-u>lua require'search'.prompt('', fn.get_visual_selection())<CR>", desc = "Search & replace" },
    ["<S-Tab>"]         = { "<gv" },
    ["<Tab>"]           = { ">gv" },
    c                   = { '"_c' },
    d                   = { '"_d' },
    h                   = { ";" },
    l                   = { "h" },
    P                   = { "p" },
    p                   = { "P" },
    y                   = { "ygv" },
  }, --}}}
}
