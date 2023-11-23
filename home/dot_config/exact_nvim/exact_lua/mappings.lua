-- vim: fcl=all fdm=marker fdl=0 fen

--{{{ Helpers
local function close_folds_at(level)
  return function()
    fn.close_folds_at(level or vim.fn.foldlevel('.'))
  end
end

local function copy_cursor_location()
  fn.copy_line_info('%s:%d:%d')
end

local function del_cur_bookmark()
  fn.del_bookmark()
end

local function edit(view)
  return function()
    fn.edit_buffer(view, vim.fn.expand('<cfile>'))
  end
end

local function get_map_expr(key)
  return ([[(v:count!=0||mode(1)[0:1]=='no'?'%s':'g%s')]]):format(key, key)
end

local function get_map_expr_i(key)
  return ([[(v:count!=0||mode(1)[0:1]=='no'?'%s':'<C-o>g%s')]]):format(key, key)
end

local function goto_bookmark(tag)
  return function()
    fn.goto_bookmark(tag)
  end
end

local function open_file_in_github()
  fn.open_in_github()
end

local function search_and_replace()
  require'search'.prompt()
end

local function search_git_history()
  return require'fzf-lua'.fzf_live(
    [[git rev-list --all | xargs git grep --line-number --column --color=always <query>]],
    {
      fzf_opts = {
        ['--delimiter'] = ':',
        ['--preview-window'] = 'nohidden,down,60%,border-top,+{3}+3/3,~3',
      },
      preview = [[git show {1}:{2} | bat --style=default --color=always --file-name={2} --highlight-line={3}]],
    }
)
end

local function send_term(cmd)
  return function()
    fn.send_terminal(cmd, true)
  end
end

local function show(fn)
  return function()
    require'fzf-lua'[fn]()
  end
end

local function show_jumps(dir)
  return function()
    fn.show_buffer_jump_picker(dir)
  end
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
    ["<M-b>"]           = { [[<C-o>b]], noremap = false },
    ["<M-e>"]           = { [[<C-o>e]], noremap = false },
    ["<M-j>"]           = { "'<C-o>'."..get_map_expr("<Down>"), expr = true },
    ["<M-k>"]           = { "'<C-o>'."..get_map_expr("<Up>"), expr = true },
    ["<M-l>"]           = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up><End>':'<Left>'", expr = true },
    ["<M-w>"]           = { [[<C-o>w]], noremap = false },
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
    ["<C-1>"]           = { send_term'!!' },
    ["<C-c>"]           = { "<cmd>tabclose<CR>" },
    ['<C-d>']           = { [[<C-d>zz]] },
    ["<C-Down>"]        = { "<C-w>j" },
    ['<C-i>']           = { '<Nop>' },
    ["<C-Left>"]        = { "<C-w>h" },
    ['<C-o>']           = { '<Nop>' },
    ["<C-Right>"]       = { "<C-w>l" },
    ["<C-Tab>"]         = { show'loclist' },
    ['<C-u>']           = { [[<C-u>zz]] },
    ["<C-Up>"]          = { "<C-w>k" },
    ["<C-w><C-f>"]      = { edit'vsplit', desc = "Edit in vert split" },
    ["<C-w>f"]          = { edit'split', desc = "Edit in split" },
    ["<C-w>gf"]         = { "<cmd>tabe <cfile><CR>", desc = "Edit in tab" },
    ["<C-z>"]           = { fn.open_terminal },
    ["<End>"]           = { "$", noremap = false },
    ["<Enter>"]         = { update_file, silent = false },
    ["<F1>"]            = { ":lua fn.ui_try(vim.cmd.help, vim.fn.expand('<cword>'))<CR>" },
    ["<Home>"]          = { "^", noremap = false },
    ["<Left>"]          = { "col('.')==1&&col([line('.')-1,'$'])>1?'<Up><End><Right>':'<Left>'", expr = true },
    ["<leader><Space>"] = { show'files', desc = "Files" },
    ['<leader>ac']      = { [[<cmd>lua fn.ai_conv('CodeConv')<CR>]], desc = "Conv code" },
    ['<leader>ad']      = { [[<cmd>lua fn.ai_gen('ApiDoc')<CR>]], desc = "Doc gen" },
    ["<leader>c"]       = { [[<cmd>copen<CR>]], desc = "Open quickfix" },
    ['<leader>db']      = { show'dap_breakpoints', desc = "Breakpoints" },
    ['<leader>de']      = { fn.resume_debugging, desc = "Enter Debugger" },
    ["<leader>fd"]      = { fn.delete_file, desc = "Delete" },
    ["<leader>fe"]      = { fn.edit_file, desc = "Edit" },
    ["<leader>fm"]      = { fn.move_file, desc = "Move" },
    ["<leader>fo"]      = { fn.open_file_folder, desc = "Open folder" },
    ["<leader>fs"]      = { fn.save_file, desc = "Save" },
    ["<leader>gb"]      = { "<cmd>Gitsigns blame_line<CR>", desc = "Blame line" },
    ["<leader>gc"]      = { show'git_commits', desc = "Commits" },
    ["<leader>gf"]      = { show'git_bcommits', desc = "File commits" },
    ["<leader>gg"]      = { fn.open_git_repo, desc = "Open repo in github" },
    ["<leader>gN"]      = { "<cmd>Gitsigns prev_hunk<CR>", desc = "Prev hunk" },
    ["<leader>gn"]      = { "<cmd>Gitsigns next_hunk<CR>", desc = "Next hunk" },
    ["<leader>gp"]      = { "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview hunk" },
    ["<leader>go"]      = { open_file_in_github, desc = "Open file in Github" },
    ["<leader>gr"]      = { ":Gitsigns reset_hunk<CR>", desc = "Reset hunk" },
    ["<leader>gs"]      = { search_git_history, desc = "Search history" },
    ["<leader>id"]      = { show'diagnostics_document', desc = "Document issues" },
    ["<leader>iw"]      = { show'diagnostics_workspace', desc = "Workspace issues" },
    ["<leader>l"]       = { show'lsp_document_symbols', desc = "LSP symbols" },
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
    ["<M-=>"]           = { "<cmd>tabe %<CR>" },
    ["<M-;>"]           = { "v:lua.fn.is_floating()?'l':'<C-w>l'", expr = true },
    ["<M-j>"]           = { "v:lua.fn.is_floating()?'j':'<C-w>j'", expr = true },
    ["<M-k>"]           = { "v:lua.fn.is_floating()?'k':'<C-w>k'", expr = true },
    ["<M-l>"]           = { "v:lua.fn.is_floating()?'h':'<C-w>h'", expr = true },
    ["<PageDown>"]      = { "L<Down>", noremap = false },
    ["<PageUp>"]        = { "H<Up>", noremap = false },
    ['<S-Tab><S-Tab>']  = { show_jumps'forward', desc = "Forward jumps" },
    ['<Tab><Tab>']      = { show_jumps'backward', desc = "Backward jumps" },
    ["<Tab>1"]          = { goto_bookmark(1), desc = "Bookmark 1" },
    ["<Tab>2"]          = { goto_bookmark(2), desc = "Bookmark 2" },
    ["<Tab>3"]          = { goto_bookmark(3), desc = "Bookmark 3" },
    ["<Tab>4"]          = { goto_bookmark(4), desc = "Bookmark 4" },
    ["<Tab>5"]          = { goto_bookmark(5), desc = "Bookmark 5" },
    ["<Tab><BS>"]       = { del_cur_bookmark, desc = "Delete bookmark" },
    [";"]               = { "l" },
    ['\\']              = { [[:nohlsearch<CR>]] },
    C                   = { '"_C' },
    c                   = { '"_c' },
    D                   = { '"_D' },
    d                   = { '"_d' },
    gf                  = { edit'edit', desc = "Edit" },
    h                   = { ";" },
    l                   = { "col('.')==1&&col([line('.')-1,'$'])>1?'k$l':'h'", expr = true },
    x                   = { "col('$')==col('.')?'gJ':'\"_x'", expr = true },
    ['y.']              = { copy_cursor_location, desc = "Copy cursor location" },
    yD                  = { 'D', desc = "Cut text after cursor" },
    yd                  = { 'dd', desc = "Cut line" },
    yx                  = { "col('$')==col('.')?'gJ':'x'", expr = true, desc = "Cut character under cursor" },
    z0                  = { close_folds_at(), desc = "Close all folds at current level" },
    z1                  = { close_folds_at(1), desc = "Close all level 1 folds" },
    z2                  = { close_folds_at(2), desc = "Close all level 2 folds" },
    z3                  = { close_folds_at(3), desc = "Close all level 3 folds" },
  }, --}}}
  t = { --{{{
    ["<C-`>"]           = { fn.toggle_terminal },
    ["<C-;>"]           = { "<End>" },
    ["<C-1>"]           = { send_term'!!' },
    ["<C-Left>"]        = { "<Home>" },
    ["<C-l>"]           = { "<Home>" },
    ["<C-Right>"]       = { "<End>" },
    ["<Esc>"]           = { [[!v:lua.fn.is_floating()?'<Esc>':'<C-\\><C-n>']], expr = true },
    ["<LeftMouse>"]     = { "<nop>" },
    ["<M-;>"]           = { "<Right>" },
    ["<M-j>"]           = { "<C-\\><C-n>j" },
    ["<M-k>"]           = { "<C-\\><C-n>k" },
    ["<M-l>"]           = { "<Left>" },
    ["<PageDown>"]      = { "<C-\\><C-n>L<Down>" },
    ["<PageUp>"]        = { "<C-\\><C-n>H<Up>" },
  }, --}}}
  x = { --{{{
    [";"]               = { "l" },
    ["<F1>"]            = { ":<C-u>lua fn.ui_try(vim.cmd.help,fn.get_visual_selection())<CR>" },
    ['<leader>ac']      = { [[:<C-u>lua fn.ai_conv('CodeConv',fn.get_visual_selection())<CR>]], desc = "Code conv" },
    ['<leader>ad']      = { [[:<C-u>lua fn.ai_gen('ApiDoc',fn.get_visual_selection())<CR>]], desc = "Doc gen" },
    ["<leader>go"]      = { open_file_in_github, desc = "Open in Github" },
    ["<leader>s"]       = { ":<C-u>lua require'search'.prompt('',fn.get_visual_selection())<CR>", desc = "Search & replace" },
    ['<leader>y']       = { [[:<C-u>lua fn.screenshot_selected_code()<CR>]], desc = "Screenshot selected code" },
    ["<S-Tab>"]         = { "<gv" },
    ["<Tab>"]           = { ">gv" },
    ['/']               = { [['<Esc>/\%>'.min([line('.'),line('v')]).'l\%<'.max([line('.'),line('v')]).'l']], expr = true, silent = false },
    ['?']               = { [['<Esc>?\%>'.min([line('.'),line('v')]).'l\%<'.max([line('.'),line('v')]).'l']], expr = true, silent = false },
    c                   = { '"_c' },
    d                   = { '"_d' },
    h                   = { ";" },
    l                   = { "h" },
    P                   = { "p" },
    p                   = { "P" },
    y                   = { "ygv" },
  }, --}}}
}
