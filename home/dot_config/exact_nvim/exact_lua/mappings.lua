-- vim: fcl=all fdm=marker fdl=0 fen

--{{{ Helpers
local function call(fun, ...)
  local args = { ... }
  return function()
    fn.ui_try(fun, unpack(args))
  end
end

local function edit_buf(view)
  return call(fn.edit_buffer, view, vim.fn.expand('<cfile>'))
end

local function update_buf()
  if fn.is_empty_buffer() then
    fn.save_file()
  else
    fn.ui_try(vim.cmd.update, { mods = { silent = true } })
  end
end

local function open_help()
  return fn.ui_try(vim.cmd.help, vim.fn.expand('<cword>'))
end

local function get_map_expr(key)
  return ([[(v:count!=0||mode(1)[0:1]=='no'?'%s':'g%s')]]):format(key, key)
end

local function get_map_expr_i(key)
  return ([[(v:count!=0||mode(1)[0:1]=='no'?'%s':'<C-o>g%s')]]):format(key, key)
end

local function get_motion_expr(if_then, if_else)
  return ([[col('.')==1&&col([line('.')-1,'$'])>1?'%s':'%s']]):format(if_then, if_else)
end

local function search_history()
  vim.ui.input({
      prompt = " 󱉶 Search term: ",
      dressing = {
        relative = 'editor',
      },
    },
    function(term)
      if term and #term > 0 then
        fn.show_file_history(nil, term)
      end
    end)
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
    ["<M-l>"]           = { get_motion_expr('<Up><End>', '<Left>'), expr = true },
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
    ["<C-`>"]           = { call(fn.toggle_terminal) },
    ["<C-c>"]           = { call(vim.cmd.tabclose) },
    ['<C-d>']           = { [[<C-d>zz]] },
    ["<C-Down>"]        = { "<C-w>j" },
    ['<C-i>']           = { '<Nop>' },
    ["<C-Left>"]        = { "<C-w>h" },
    ['<C-o>']           = { '<Nop>' },
    ["<C-Right>"]       = { "<C-w>l" },
    ["<C-Tab>"]         = { call(fn.search, 'loclist') },
    ['<C-u>']           = { [[<C-u>zz]] },
    ["<C-Up>"]          = { "<C-w>k" },
    ["<C-w><C-f>"]      = { edit_buf'vsplit', desc = "Edit in vert split" },
    ["<C-w>f"]          = { edit_buf'split', desc = "Edit in split" },
    ["<C-w>gf"]         = { call(vim.cmd.tabedit, '<cfile>'), desc = "Edit in tab" },
    ["<C-z>"]           = { call(fn.open_terminal) },
    ["<End>"]           = { "$", noremap = false },
    ["<Enter>"]         = { update_buf, silent = false },
    ["<F1>"]            = { open_help },
    ["<Home>"]          = { "^", noremap = false },
    ["<Left>"]          = { get_motion_expr('<Up><End><Right>', '<Left>'), expr = true },
    ["<leader><Space>"] = { call(fn.search, 'find_files'), desc = "Files" },
    ['<leader>ac']      = { call(fn.ai_conv, 'CodeConv'), desc = "Conv code" },
    ['<leader>ad']      = { call(fn.ai_gen, 'ApiDoc'), desc = "Doc gen" },
    ['<leader>db']      = { call(fn.search, 'dap_breakpoints'), desc = "Breakpoints" },
    ['<leader>dd']      = { call(fn.toggle_debug_repl), desc = "Toggle REPL" },
    ['<leader>de']      = { call(fn.resume_debugging), desc = "Enter Debugger" },
    ["<leader>fd"]      = { call(fn.delete_file), desc = "Delete" },
    ["<leader>fe"]      = { call(fn.edit_file), desc = "Edit" },
    ["<leader>fm"]      = { call(fn.move_file), desc = "Move" },
    ["<leader>fo"]      = { call(fn.open_file_folder), desc = "Open folder" },
    ["<leader>fs"]      = { call(fn.save_file), desc = "Save" },
    ["<leader>gb"]      = { call(vim.cmd.Gitsigns, 'blame_line'), desc = "Blame line" },
    ["<leader>gd"]      = { call(vim.cmd.DiffviewOpen), desc = "Show diff" },
    ["<leader>gg"]      = { call(fn.open_git_repo), desc = "Open repo in github" },
    ["<leader>gh"]      = { call(fn.show_file_history), desc = "Show file history" },
    ["<leader>gj"]      = { call(vim.cmd.Gitsigns, 'next_hunk'), desc = "Next hunk" },
    ["<leader>gk"]      = { call(vim.cmd.Gitsigns, 'prev_hunk'), desc = "Prev hunk" },
    ["<leader>gp"]      = { call(vim.cmd.Gitsigns, 'preview_hunk'), desc = "Preview hunk" },
    ["<leader>go"]      = { call(fn.open_in_github), desc = "Open file in Github" },
    ["<leader>gr"]      = { call(vim.cmd.Gitsigns, 'reset_hunk'), desc = "Reset hunk" },
    ["<leader>gs"]      = { search_history, desc = "Search history" },
    ["<leader>id"]      = { call(fn.search, 'diagnostics_document'), desc = "Document issues" },
    ["<leader>iw"]      = { call(fn.show_lsp_diagnostics_list), desc = "Workspace issues" },
    ["<leader>l"]       = { call(fn.search, 'lsp_document_symbols'), desc = "LSP symbols" },
    ["<leader>pa"]      = { call(vim.cmd.Mason), desc = "Packages" },
    ["<leader>pl"]      = { call(vim.cmd.Lazy), desc = "Plugins" },
    ["<leader>q1"]      = { call(fn.show_task_output, 1), desc = "Log 1" },
    ["<leader>q2"]      = { call(fn.show_task_output, 2), desc = "Log 2" },
    ["<leader>q3"]      = { call(fn.show_task_output, 3), desc = "Log 3" },
    ["<leader>q4"]      = { call(fn.show_task_output, 4), desc = "Log 4" },
    ["<leader>q5"]      = { call(fn.show_task_output, 5), desc = "Log 5" },
    ["<leader>q6"]      = { call(fn.show_task_output, 6), desc = "Log 6" },
    ["<leader>qq"]      = { call(fn.show_messages_list), desc = "Messages" },
    ["<leader>s"]       = { call(require'search'.prompt), desc = "Search & replace" },
    ["<leader>t"]       = { call(vim.cmd.OverseerRun), desc = "Tasks" },
    ["<leader>X"]       = { call(vim.cmd.quitall), desc = "Quit" },
    ["<leader>x"]       = { call(fn.close_window), desc = "Close" },
    ["<leader>z"]       = { call(fn.zoom_window), desc = "Zoom" },
    ["<M-\\>"]          = { call(vim.cmd.vsplit) },
    ["<M-->"]           = { call(vim.cmd.split) },
    ["<M-=>"]           = { call(vim.cmd.tabedit, '%') },
    ["<M-;>"]           = { "v:lua.fn.is_floating()?'l':'<C-w>l'", expr = true },
    ["<M-j>"]           = { "v:lua.fn.is_floating()?'j':'<C-w>j'", expr = true },
    ["<M-k>"]           = { "v:lua.fn.is_floating()?'k':'<C-w>k'", expr = true },
    ["<M-l>"]           = { "v:lua.fn.is_floating()?'h':'<C-w>h'", expr = true },
    ["<PageDown>"]      = { "L<Down>", noremap = false },
    ["<PageUp>"]        = { "H<Up>", noremap = false },
    ['<S-Tab><S-Tab>']  = { call(fn.show_buffer_jump_picker, 'forward'), desc = "Forward jumps" },
    ['<Tab><Tab>']      = { call(fn.show_buffer_jump_picker, 'backward'), desc = "Backward jumps" },
    ["<Tab>1"]          = { call(fn.goto_bookmark, 1), desc = "Bookmark 1" },
    ["<Tab>2"]          = { call(fn.goto_bookmark, 2), desc = "Bookmark 2" },
    ["<Tab>3"]          = { call(fn.goto_bookmark, 3), desc = "Bookmark 3" },
    ["<Tab>4"]          = { call(fn.goto_bookmark, 4), desc = "Bookmark 4" },
    ["<Tab>5"]          = { call(fn.goto_bookmark, 5), desc = "Bookmark 5" },
    ["<Tab><BS>"]       = { call(fn.del_bookmark), desc = "Delete bookmark" },
    [";"]               = { "l" },
    C                   = { '"_C' },
    c                   = { '"_c' },
    D                   = { '"_D' },
    d                   = { '"_d' },
    gf                  = { edit_buf'edit', desc = "Edit" },
    h                   = { ";" },
    l                   = { get_motion_expr('k$l', 'h'), expr = true },
    x                   = { "col('$')==col('.')?'gJ':'\"_x'", expr = true },
    ['y.']              = { call(fn.copy_line_info, '%s:%d:%d'), desc = "Copy cursor location" },
    yD                  = { 'D', desc = "Cut text after cursor" },
    yd                  = { 'dd', desc = "Cut line" },
    yx                  = { "col('$')==col('.')?'gJ':'x'", expr = true, desc = "Cut character under cursor" },
    z0                  = { call(fn.close_folds_at), desc = "Close all folds at current level" },
    z1                  = { call(fn.close_folds_at, 1), desc = "Close all level 1 folds" },
    z2                  = { call(fn.close_folds_at, 2), desc = "Close all level 2 folds" },
    z3                  = { call(fn.close_folds_at, 3), desc = "Close all level 3 folds" },
  }, --}}}
  t = { --{{{
    ["<C-`>"]           = { call(fn.toggle_terminal) },
    ["<C-;>"]           = { "<End>" },
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
    ["<leader>gh"]      = { [[:<C-u>lua fn.show_file_history{vim.fn.getpos("'<")[2],vim.fn.getpos("'>")[2]}<CR>]], desc = "Show line history" },
    ["<leader>go"]      = { call(fn.open_in_github), desc = "Open in Github" },
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
