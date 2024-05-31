-- vim: fcl=all fdm=marker fdl=0 fen

local fn = {}

--{{{ Helpers
local function create_parent_dirs(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end

local function resolve_path(tabpageOrPath)
  return type(tabpageOrPath) == "string"
    and tostring(vim.fn.expand(tabpageOrPath))
    or fn.get_tab_cwd(tabpageOrPath)
end
--}}}

--{{{ Misc
function fn.get_tab_cwd(tabpage)
  local has_var, cwd = pcall(
    vim.api.nvim_tabpage_get_var,
    tabpage or vim.api.nvim_get_current_tabpage(),
    "cwd"
  )
  return has_var and cwd or vim.fn.getcwd(-1)
end

function fn.set_tab_cwd(tabpage, path)
  local cwd = path or vim.fn.getcwd(-1)
  vim.api.nvim_tabpage_set_var(
    tabpage or vim.api.nvim_get_current_tabpage(),
    "cwd",
    cwd
  )
  vim.cmd.tcd(cwd)
end

function fn.expand_each(list)
  local result = {}
  for _, item in ipairs(list) do
    table.insert(result, vim.fn.expand(item))
  end
  return vim.fn.join(result)
end

function fn.is_empty_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  if name and #name > 0 and vim.fn.fnamemodify(name, ":t") ~= "new" then
    return false
  end
  local lines = vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false)
  for _, line in ipairs(lines) do
    if #line ~= 0 then
      return false
    end
  end
  return true
end

function fn.is_filename_empty(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  return #name == 0 or vim.fn.fnamemodify(name, ':t') == 'new'
end

function fn.is_file_buffer(buf)
  if #vim.bo[buf or 0].buftype > 0 then
    return false
  end
  return not fn.is_filename_empty(buf)
end

function fn.get_wins_for_buf_type(buf_type)
  return vim.fn.filter(
    vim.fn.range(1, vim.fn.winnr("$")),
    ("getwinvar(v:val, '&bt') == '%s'"):format(buf_type))
end

function fn.vim_defer(cb, timer)
  return function()
    if cb ~= nil then
      if type(cb) == "function" then
        vim.defer_fn(cb, timer or 0)
      else
        vim.defer_fn(function()
          vim.cmd(cb)
        end, timer or 0)
      end
    end
  end
end

function fn.is_subpath(path, other)
  local path_parts = vim.split(path, "/")
  local other_parts = vim.split(other, "/")
  local common_parts = vim.list_slice(path_parts, 1, #other_parts)
  return vim.deep_equal(common_parts, other_parts)
end

function fn.expand_path(path)
  if vim.fn.has("win32") == 1 then
    local shellslash = vim.o.shellslash
    vim.o.shellslash = false
    local expanded_path = vim.fn.expand(path)
    vim.o.shellslash = shellslash
    return expanded_path
  end
  return vim.fn.expand(path)
end

function fn.env_str(string)
  if vim.fn.has("win32") == 1 then
    return vim.trim(vim.fn.system(("cygpath -w \"%s\""):format(string)))
  end
  return vim.trim(vim.fn.system(("echo \"%s\""):format(string)))
end

function fn.path_str(string)
  if vim.fn.has("win32") == 1 then
    return vim.trim(vim.fn.system(("cygpath -pw \"%s\""):format(string)))
  end
  return vim.trim(vim.fn.system(("echo \"%s\""):format(string)))
end

function fn.get_highlight_color_bg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name })
  return hl.bg and ('#%06X'):format(hl.bg) or "#000000"
end

function fn.get_highlight_color_fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name })
  return hl.fg and ('#%06X'):format(hl.fg) or "#000000"
end

function fn.apply_unfocused_highlight()
  local focused_hl_ns = vim.api.nvim_create_namespace('hl_focused')
  local normal_hl = vim.api.nvim_get_hl(focused_hl_ns, { name = 'Normal' })
  if normal_hl.bg == nil then
    normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
    local normalnc_hl = vim.api.nvim_get_hl(0, { name = 'NormalNC' })
    local winsep_hl = vim.api.nvim_get_hl(0, { name = 'WinSeparator' })
    vim.api.nvim_set_hl(focused_hl_ns, 'Normal', normal_hl)
    vim.api.nvim_set_hl(focused_hl_ns, 'NormalNC', normalnc_hl)
    vim.api.nvim_set_hl(focused_hl_ns, 'WinSeparator', winsep_hl)
  end
  local unfocused_bg = require'catppuccin.palettes'.get_palette('macchiato').base
  local unfocused_sep = require'catppuccin.palettes'.get_palette('macchiato').crust
  vim.api.nvim_set_hl(0, 'Normal', { bg = unfocused_bg })
  vim.api.nvim_set_hl(0, 'NormalNC', { bg = unfocused_bg })
  vim.api.nvim_set_hl(0, 'WinSeparator', { fg = unfocused_sep })
end

function fn.apply_focused_highlight()
  local focused_hl_ns = vim.api.nvim_create_namespace('hl_focused')
  local normal_hl = vim.api.nvim_get_hl(focused_hl_ns, { name = 'Normal' })
  local normalnc_hl = vim.api.nvim_get_hl(focused_hl_ns, { name = 'NormalNC' })
  local winsep_hl = vim.api.nvim_get_hl(focused_hl_ns, { name = 'WinSeparator' })
  if normal_hl.bg ~= nil then
    vim.api.nvim_set_hl(0, 'Normal', normal_hl)
    vim.api.nvim_set_hl(0, 'NormalNC', normalnc_hl)
    vim.api.nvim_set_hl(0, 'WinSeparator', winsep_hl)
  end
end

function fn.foldfunc(close, start_open, open, sep, mid_sep, end_sep)
  local C = require'ffi'.C
  return function(args)
    local width = C.compute_foldcolumn(args.wp, 0)
    if C.compute_foldcolumn(args.wp, 0) == 0 then
      return ''
    end

    local foldinfo = C.fold_info(args.wp, args.lnum)

    local string = args.cul and args.relnum == 0
      and '%#CursorLineFold#'
      or '%#FoldColumn#'

    if foldinfo.level == 0 then
      return string..(' '):rep(width)..'%*'
    end

    if foldinfo.lines > 0 then
      string = string..close
    elseif foldinfo.start == args.lnum then
      local prev_foldinfo = C.fold_info(args.wp, args.lnum - 1)
      if prev_foldinfo.level == 0 then
        string = string..start_open
      else
        string = string..open
      end
    else
      local next_foldinfo = C.fold_info(args.wp, args.lnum + 1)
      if next_foldinfo.level == 0 then
        string = string..end_sep
      else
        if next_foldinfo.start ~= foldinfo.start
          and next_foldinfo.level <= foldinfo.level then
          string = string..mid_sep
        else
          string = string..sep
        end
      end
    end
    return string..'%*'
  end
end

function fn.is_floating(win)
  return vim.api.nvim_win_get_config(win or 0).relative ~= [[]]
end

function fn.is_in_unfocusable(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf or vim.api.nvim_get_current_buf())) do
    if not vim.api.nvim_win_get_config(win).focusable then
      return true
    end
  end
  return false
end

function fn.is_in_floating(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf or vim.api.nvim_get_current_buf())) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      return true
    end
  end
  return false
end

function fn.get_visual_line_range()
  return {
    vim.fn.getpos[['<]][2],
    vim.fn.getpos[['>]][2],
  }
end

function fn.get_visual_selection()
  local s_start = vim.fn.getpos[['<]]
  local s_end = vim.fn.getpos[['>]]
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = lines[1]:sub(s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = lines[n_lines]:sub(1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = lines[n_lines]:sub(1, s_end[3] + 1)
  end
  return table.concat(lines, '\n')
end

function fn.copy_visual_selection()
  vim.fn.setreg('+', fn.get_visual_selection())
end

function fn.get_buffer_title(buf)
  return fn.is_file_buffer(buf)
    and vim.fn.pathshorten(vim.fn.expand('%:~:.'))
    or vim.bo[buf or 0].filetype
    or vim.bo[buf or 0].buftype
end

function fn.get_line_info(format, win)
  local file_win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(file_win)
  local filename = vim.api.nvim_buf_get_name(buf)
  local cursor
  if win and vim.fn.mode():sub(1, 1):lower() == 'v' then
    cursor = { vim.fn.getpos("'<"), vim.fn.getpos("'>") }
  else
    cursor = vim.api.nvim_win_get_cursor(file_win)
  end
  return format:format(filename, cursor[1], cursor[2])
end

function fn.copy_line_info(format, win)
  vim.fn.setreg('+', fn.get_line_info(format, win))
end

function fn.screenshot_selected_code()
  fn.copy_visual_selection()
  fn.exec_task(
    'silicon',
    {
      '--from-clipboard',
      '--language',
      vim.bo.filetype,
      '--to-clipboard',
    },
    "Screenshot selected code")
end

local function make_file_switcher_entry()
  local make_display = function(entry)
    local filename = vim.fn.pathshorten(vim.fn.fnamemodify(entry.filename, ':~:.'))
    local displayer = require'telescope.pickers.entry_display'.create {
      separator = ' ',
      items = {
        { width = 1 },
        { width = #filename },
        { remaining = true },
      },
    }
    local file_label = vim.fn.fnamemodify(filename, ':t')
    local file_ext = vim.fn.fnamemodify(filename, ':e')
    local icon, hl = require'nvim-web-devicons'.get_icon(file_label, file_ext)
    return displayer {
      {
        icon,
        hl,
      },
      filename,
      {
        entry.lnum..':'..entry.col,
        'TelescopeResultsLineNr',
      },
    }
  end

  return function(entry)
    local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)
    return {
      col = entry.col,
      display = make_display,
      filename = filename,
      finish = entry.finish,
      lnum = entry.lnum,
      ordinal = filename..' '..entry.text,
      start = entry.start,
      text = entry.text,
      valid = true,
      value = entry,
    }
  end
end

function fn.search(obj)
  local lib = require'telescope.builtin'

  local opts = {}

  if obj == 'dap_breakpoints' then
    lib = require'telescope'.extensions.dap

    obj = 'list_breakpoints'
  elseif obj == 'diagnostics_document' then
    obj = 'diagnostics'

    opts = {
      bufnr = 0,
    }
  elseif obj == 'diagnostics_workspace' then
    obj = 'diagnostics'
  elseif obj == 'find_files' then
    opts = {
      find_command = {
        vim.o.shell,
        vim.o.shellcmdflag,
        vim.o.grepprg..' --files',
      },
    }
  elseif obj == 'loclist' then
    opts = {
      attach_mappings = function(_, map)
        map('i', [[<Tab>]], function(bufnr)
          require'telescope.actions.set'.edit(bufnr, 'edit')
        end)
        return true
      end,
      entry_maker = make_file_switcher_entry(),
      layout_strategy = 'vertical',
      layout_config = {
        height = 0.50,
        width = 0.30,
      },
    }
  end

  lib[obj](opts)
end

function fn.open_folder(path)
  local shellslash
  if vim.fn.has('win32') == 1 then
    shellslash = vim.o.shellslash
    vim.o.shellslash = false
    path = path and path:gsub('/', '\\')
  end
  local folder = path or fn.get_tab_cwd()
  if vim.fn.has('win32') == 1 then
    vim.o.shellslash = shellslash
  end
  fn.open_in_os{ folder }
end

function fn.open_file_folder(path)
  local folder = path
    and vim.fn.fnamemodify(path, ':p:h')
    or vim.fn.expand'%:p:h'
  fn.open_folder(folder)
end

function fn.get_sign_for_severity(severity)
  local suffix
  if type(severity) == 'number' then
    local s = vim.diagnostic.severity
    local severities = {
      [s.ERROR] = 'Error',
      [s.WARN] = 'Warn',
      [s.HINT] = 'Hint',
      [s.INFO] = 'Info',
    }
    suffix = severities[severity]
  elseif type(severity) == 'string' then
    suffix = vim.trim(severity)
    if #severity == 1 then
      local severities = {
        E = 'Error',
        W = 'Warn',
        N = 'Hint',
        I = 'Info',
      }
      suffix = severities[severity:upper()]
    end
  end
  if not suffix or #suffix == 0 then
    return nil, nil
  end
  local name = 'DiagnosticSign'..suffix
  return vim.fn.sign_getdefined(name)[1].text, name
end
--}}}
--{{{ UI
function fn.delete_file()
  local rel_file = vim.fn.pathshorten(vim.fn.expand('%:~:.'))

  vim.ui.select({ 'No', 'Yes' }, {
    prompt = " 󰆴 Delete "..rel_file.."?",
    dressing = {
      relative = 'win',
    },
  }, function(choice)
    if choice == 'Yes' then
      vim.fn.delete(tostring(vim.fn.expand('%:p')))
      require'mini.bufremove'.wipeout()
    end
  end)
end

function fn.edit_file()
  local rel_dir = vim.fn.expand("%:~:.:h")
  vim.ui.input({
      completion = "dir",
      default = rel_dir.."/",
      prompt = " 󱇧 Edit at: ",
      dressing = {
        relative = "win",
      },
    },
    function(path)
      if path == nil or #path == 0 or path == rel_dir or path.."/" == rel_dir then
        return
      end
      create_parent_dirs(path)
      vim.cmd.edit(path)
    end)
end

function fn.move_file()
  local rel_file = vim.fn.expand("%:~:.")
  vim.ui.input({
      completion = "file",
      default = rel_file,
      prompt = " 󰪹 Move to: ",
      dressing = {
        relative = "win",
      },
    },
    function(path)
      if path == nil or #path == 0 or path == rel_file then
        return
      end
      create_parent_dirs(path)
      vim.cmd.saveas(path)
      vim.fn.delete(tostring(vim.fn.expand("#")))
      vim.cmd.bwipeout[[#]]
    end)
end

function fn.save_file()
  local rel_file = vim.fn.expand('%:~:.')
  vim.ui.input({
      completion = 'file',
      default = rel_file,
      prompt = " 󰈔 Save to: ",
      dressing = {
        relative = 'win',
      },
    },
    function(path)
      if path == nil or #path == 0 or path == rel_file then
        return
      end
      create_parent_dirs(path)
      vim.cmd.saveas(path)
    end)
end

function fn.ui_input(opts)
  return function()
    return coroutine.create(function(coro)
      vim.ui.input(vim.tbl_extend('keep', opts, {
        dressing = {
          relative = opts.relative or 'editor',
        },
      }), function(input)
        if input then
          coroutine.resume(coro, opts.callback and opts.callback(input) or input)
        end
      end)
    end)
  end
end

function fn.ui_try(callback, ...)
  local is_ok, result = pcall(callback, ...)
  if is_ok then
    return result
  end
  vim.notify(result, vim.log.levels.ERROR, { title = 'help' })
end

function fn.close_folds_at(level)
  level = level or vim.fn.foldlevel('.')

  local line = 1
  local last = vim.fn.line('$')
  while line < last do
    if vim.fn.foldclosed(line) ~= -1 then
      line = vim.fn.foldclosedend(line) + 1
    elseif vim.fn.foldlevel(line) == level then
      vim.cmd.foldclose{ range = { line } }
      line = vim.fn.foldclosedend(line) + 1
    else
      line = line + 1
    end
  end
end

function fn.popup_preview(opts)
  local buf = opts.buf
  local col = opts.col
  local end_col = opts.end_col
  local filename = opts.filename
  local lnum = opts.lnum
  local anchor_cur = opts.anchor_cur
  local anchor_row = opts.anchor_row or 0
  local anchor_win = opts.anchor_win or vim.api.nvim_get_current_win()
  local context = opts.context or nil
  local height = opts.height or 5

  local lines
  if not buf then
    if not filename or vim.fn.filereadable(filename) == 0 then
      return nil
    end
    buf = vim.fn.bufadd(filename)
  else
    filename = vim.api.nvim_buf_get_name(buf)
    if vim.fn.filereadable(filename) == 0 then
      return nil
    end
    if vim.api.nvim_buf_is_loaded(buf) then
      lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    end
  end

  if not lines then
    lines = vim.fn.readfile(filename)
  end

  local width = vim.api.nvim_win_get_width(anchor_win)
  local count = math.max(1, #lines)

  local half_height = (height - 1) / 2
  local top = math.min(0, lnum - 1 - half_height)
  local bot = math.min(0, count - lnum - half_height)

  local config = {
    anchor = 'SW',
    border = 'single',
    col = 0,
    focusable = false,
    height = height,
    relative = not anchor_cur and 'win' or 'cursor',
    row = not anchor_cur and anchor_row or anchor_row + bot,
    title = {
      { require'nvim-web-devicons'.get_icon(filename) },
      { ' ' },
      { vim.fn.fnamemodify(filename, ':~:.'), 'Title' },
    },
    width = width,
    win = not anchor_cur and anchor_win or nil,
  }

  if not context then
    config.noautocmd = true

    local pbuf = vim.api.nvim_create_buf(false, true)
    if pbuf ~= 0 then
      vim.bo[pbuf].bufhidden = 'wipe'
    end

    context = vim.api.nvim_open_win(pbuf, false, config)
    if context ~= 0 then
      vim.wo[context].foldcolumn = '0'
      vim.wo[context].winbar = ''
      vim.wo[context].scrolloff = height
      vim.wo[context].signcolumn = 'no'
      vim.wo[context].statuscolumn = ''
      vim.wo[context].wrap = false
    else
      context = nil
    end
  else
    vim.api.nvim_win_set_config(context, config)

    vim.wo[context].scrolloff = height
  end

  if context then
    local pbuf = vim.api.nvim_win_get_buf(context)
    if vim.b[pbuf].buf ~= buf then
      vim.b[pbuf].buf = buf

      vim.api.nvim_buf_set_lines(pbuf, 0, -1, true, lines)

      local type = vim.filetype.match{ buf = buf }
      local lang = vim.treesitter.language.get_lang(type)
      vim.treesitter.stop(pbuf)
      if lang and pcall(vim.treesitter.language.add, lang) then
        vim.treesitter.start(pbuf, lang)
      end
    end

    local off = vim.fn.getwininfo(anchor_win)[1].textoff
    off = off - vim.fn.getwininfo(context)[1].textoff
    vim.api.nvim_win_set_width(context, width - off - 1)
    vim.api.nvim_win_set_height(context, top + height + bot)

    pcall(vim.api.nvim_win_set_cursor, context, { lnum, col - 1 })

    local hl_hs = vim.api.nvim_create_namespace('hl_preview')
    pcall(vim.api.nvim_buf_set_extmark,
      pbuf, hl_hs, lnum - 1, col - 1, {
        id = pbuf,
        end_col = end_col - 1,
        hl_group = 'IncSearch',
      }
    )
  end
  return context
end
--}}}
--{{{ Search
local search_info = {
  preview_win = nil,
  preview_line = nil,
}

function fn.close_search_preview()
  if search_info.preview_win then
    if vim.api.nvim_win_is_valid(search_info.preview_win) then
      vim.api.nvim_win_close(search_info.preview_win, true)
    end
    search_info.preview_win = nil
  end
end

function fn.open_search_preview()
  local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
  local result = require'search'.get_result_at_loc{ lnum, col }
  if result then
    search_info.preview_win = fn.popup_preview {
      context = search_info.preview_win,
      col = result.col_number + 1,
      end_col = result.end_col_number + 1,
      filename = result.file_name,
      lnum = result.line_number,
      anchor_cur = true,
      anchor_row = 4,
    }
  else
    fn.close_search_preview()
  end
end

function fn.toggle_search_preview()
  if search_info.preview_win then
    fn.close_search_preview()
  else
    fn.open_search_preview()
  end
end

function fn.init_search()
  local group = vim.api.nvim_create_augroup('conf_search', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'search',
    callback = function()
      vim.api.nvim_create_autocmd('BufLeave', {
        buffer = 0,
        group = group,
        callback = fn.close_search_preview,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = 0,
        group = group,
        callback = function()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]
          if search_info.preview_line and
              search_info.preview_line ~= lnum
          then
            fn.close_search_preview()
          elseif search_info.preview_win then
            fn.open_search_preview()
          end
          search_info.preview_line = lnum
        end,
      })

      vim.api.nvim_buf_set_keymap(0, 'n', [[<Enter>]], [[]], {
        callback = function()
          if not search_info.preview_win then
            fn.open_search_preview()
          else
            require'search'.show_current_search_result('edit')
          end
        end,
      })
      vim.api.nvim_buf_set_keymap(0, 'n', [[<Esc>]], [[]], {
        callback = fn.close_search_preview,
      })
    end,
  })
end
--}}}
--{{{ Terminal
local term_info = {
  is_shell_active = false,
  shell_cmd = nil,
}

local function get_prior_tabpage()
  local tabnr = vim.fn.tabpagenr[[#]]
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.api.nvim_tabpage_get_number(tabpage) == tabnr then
      return tabpage
    end
  end
end

local function get_terminal_tabpage()
  local terminal = require'toggleterm.terminal'.get(0, true)
  return terminal and vim.api.nvim_win_get_tabpage(terminal.window)
end

local function get_terminal(start_command)
  return require'toggleterm.terminal'.Terminal:new {
    id = 0,
    cmd = vim.fn.has('win32') == 1
      and 'bash'
      or 'zsh --login',
    direction = 'tab',
    env = {
      START_COMMAND = start_command,
      STARSHIP_CONFIG = '~/.dotfiles/starship.minimal.toml',
    },
    on_exit = function()
      vim.schedule(vim.cmd.quitall)
    end,
  }
end

function fn.is_main_terminal(buf)
  local terminal = require'toggleterm.terminal'.get(0, true)
  return terminal and (not buf or terminal.bufnr == buf)
end

function fn.open_terminal(start_command)
  if not fn.is_main_terminal() then
    get_terminal(start_command):open()
  else
    local tabpage = get_terminal_tabpage()
    if tabpage and vim.api.nvim_get_current_tabpage() ~= tabpage then
      vim.api.nvim_set_current_tabpage(tabpage)
    end
  end
end

function fn.dismiss_terminal()
  local tabpage = get_terminal_tabpage()
  if vim.api.nvim_get_current_tabpage() == tabpage then
    vim.api.nvim_set_current_tabpage(get_prior_tabpage())
  end
end

function fn.toggle_terminal()
  if not get_terminal():is_focused() then
    fn.open_terminal()
  else
    fn.dismiss_terminal()
  end
end

function fn.set_terminal_dir(cwd)
  local terminal = get_terminal()
  local tabpage = vim.api.nvim_win_get_tabpage(terminal.window)
  fn.set_tab_cwd(tabpage, cwd)
  terminal.dir = cwd
end

function fn.get_last_sent_cmd()
  return term_info.shell_cmd
end

function fn.send_terminal(command, should_focus)
  if fn.is_main_terminal() then
    term_info.shell_cmd = command

    if should_focus == nil or should_focus then
      get_terminal():send(command)
    else
      local terminal = get_terminal()
      local shell_pid = vim.fn.jobpid(terminal.job_id)
      vim.fn.system('kill -s SIGUSR1 '..shell_pid)
    end
  end
end

function fn.set_shell_active(is_active, cmd, exit_code, output)
  if term_info.is_shell_active ~= is_active then
    term_info.is_shell_active = is_active

    if not is_active and not get_terminal():is_focused() then
      output = output and vim.trim(output) or ''
      vim.notify(
        #output > 0
          and output
          or ("exited with code "..exit_code),
        exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR,
        { title = cmd }
      )
    end
  end
end

function fn.is_shell_active(tabpage)
  if tabpage and tabpage ~= get_terminal_tabpage() then
    return nil
  end
  return term_info.is_shell_active
end

function fn.is_terminal_buf(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  for _, term in ipairs(require'toggleterm.terminal'.get_all(true)) do
    if term.bufnr == buf then
      return true
    end
  end
  return false
end

function fn.init_terminal_mode()
  if not fn.is_main_terminal() then
    local empty_buf = vim.api.nvim_get_current_buf()
    fn.refresh_git_info()
    fn.open_terminal('nvim')
    fn.set_terminal_dir()
    vim.cmd.tabonly()
    vim.api.nvim_buf_delete(empty_buf, { force = true })
  end
end
--}}}
--{{{ Quickfix
local qf_info = {
  task_output_ids = { 1, 2, 3, 4, 5 },
  preview_win = nil,
}

local function get_diagnostic_line(item)
  local col, end_col = item.col, item.end_col
  if item.vcol and item.vcol ~= 0 then
    col = col and col - 1
    end_col = end_col and end_col - 1
  end

  local filename = item.filename
  if item.bufnr and item.bufnr ~= 0 then
    filename = vim.api.nvim_buf_get_name(item.bufnr)
  end

  return ('%s|%s|%s|%s|%s'):format(
    item.type or '',
    (item.lnum and item.lnum ~= 0) and ('%d-%d:%d-%d'):format(
      item.lnum,
      item.end_lnum or 0,
      col or 0,
      end_col or 0
    ) or '',
    item.module or '',
    filename or '',
    item.text or ''
  )
end

local function set_qf_list(name, what, is_append)
  what = what or { lines = {} }

  local list = vim.fn.getqflist{ id = 0, items = 0, context = 0 }

  local act = is_append and 'a' or 'r'
  if not qf_info[name] and list.context.name then
    act = ' '
  end

  if what.items then
    -- convert items to lines to prevent scroll offsets from jumping
    what.efm = '%t|%l-%e:%c-%k|%o|%f|%m,%t|%l-%e:%c-%k||%f|%m,%t||||%m,||||%m'
    what.lines = vim.tbl_map(get_diagnostic_line, what.items)
    what.items = nil
  end

  local is_ok, res = pcall(vim.fn.setqflist, {}, act, vim.tbl_deep_extend('keep', {
    context = { name = name },
    id = qf_info[name],
    title = what.title,
  }, what))

  if not is_ok then
    vim.notify(res, vim.log.levels.ERROR)
  end

  list = vim.fn.getqflist{ id = 0, winid = 0 }

  if list.winid ~= 0 then
    if vim.wo[list.winid].foldenable then
      vim.wo[list.winid].foldmethod =
        vim.wo[list.winid].foldmethod
      vim.wo[list.winid].foldlevel =
        vim.wo[list.winid].foldlevel
    end
  end

  if not qf_info[name] then
    qf_info[name] = list.id
  end
end

local function get_qf_context(name)
  if not qf_info[name] then
    return {}
  end
  return vim.fn.getqflist{
    id = qf_info[name],
    context = 0,
  }.context
end

local function show_qf(name, is_foldable)
  if qf_info[name] then
    local nr = vim.fn.getqflist{
      id = qf_info[name],
      nr = 0,
    }.nr
    vim.cmd.chistory{ count = nr, mods = { silent = true } }
    vim.cmd.copen()

    if is_foldable then
      vim.wo.foldenable = true
      vim.wo.foldlevel = 2
    else
      vim.wo.foldenable = false
      vim.wo.foldlevel = vim.go.foldlevelstart
    end
  end
end

local function is_current_qf(name)
  if not qf_info[name] then
    return false
  end
  return qf_info[name] == vim.fn.getqflist{ id = 0 }.id
end

function fn.qf_fold_expr()
  local items = vim.fn.getqflist{ id = 0, items = 0 }.items
  local entry = items[vim.v.lnum]
  local level = '0'
  if entry then
    if entry.bufnr == 0 and entry.type ~= '.' then
      level = '>2'
    elseif entry.type == '>' then
      level = '3'
    else
      local child = items[vim.v.lnum + 1]
      if child and child.type == '>' then
        level = '>3'
      else
        level = '2'
      end
    end
  end
  return level
end

local function qf_diagnostics_lines(items)
  local lines = {}
  for _, item in ipairs(items) do
    local line
    if item.bufnr == 0 then
      if #item.type == 0 then
        line = {{ item.text, 'Title' }}
      else
        local sign, sign_hl = fn.get_sign_for_severity(item.type)
        if sign then
          line = {
            { '  ' },
            { sign, sign_hl },
            { item.text, 'Title' },
          }
        else
          line = {
            { '    ' },
            { item.text, 'Comment' },
          }
        end
      end
      if line then
        table.insert(lines, line)
      end
    else
      local msg_len = 50
      local message = vim.fn.join(vim.split(item.text, '\n'), '↪')
      local filename = vim.fn.fnamemodify(
        vim.api.nvim_buf_get_name(item.bufnr), ':t')

      line = {
        { item.type == '>' and '      ' or '    ' },
        { message:sub(1, msg_len), 'Normal' },
        #message > msg_len and { '...', 'Comment' } or { '' },
        { '  ' },
        {
          ('%s:%d:%d'):format(
            filename,
            item.lnum,
            item.col
          ),
          'Comment',
        },
      }
      table.insert(lines, line)
    end
  end
  return lines
end

local function qf_notifications_lines(items)
  local lines = {}
  for _, item in ipairs(items) do
    local line
    if #item.type == 1 then
      local sign, sign_hl = fn.get_sign_for_severity(item.type)
      line = {
        { sign, sign_hl },
        { item.text, 'Title' },
      }
    else
      line = {
        { '  ' },
        { item.text },
      }
    end
    if line then
      table.insert(lines, line)
    end
  end
  return lines
end

function fn.qf_text(info)
  local list = vim.fn.getqflist {
    id = info.id,
    idx = 0,
    context = 0,
    items = 0,
    qfbufnr = 0,
  }

  local lines = {}
  if list.context.name == 'lsp_diagnostics' then
    lines = qf_diagnostics_lines(list.items)
  elseif list.context.name == 'notifications' then
    lines = qf_notifications_lines(list.items)
  end

  vim.schedule(function()
    local ns = vim.api.nvim_create_namespace('hl_qf_text')

    vim.api.nvim_buf_clear_namespace(list.qfbufnr, ns, 0, -1)

    for lnum, line in ipairs(lines) do
      pcall(vim.api.nvim_buf_set_extmark,
        list.qfbufnr, ns,
        lnum - 1, 0, {
          id = lnum,
          priority = 101,
          virt_text = line,
          virt_text_pos = 'overlay',
        }
      )
    end
  end)

  local content = {}
  for _, line in ipairs(lines) do
    local texts = {}
    for _, comp in ipairs(line) do
      table.insert(texts, comp[1])
    end
    table.insert(content, vim.fn.join(texts, ''))
  end
  return content
end

local function get_has_diagnostic_at_loc(location)
  local lnum, col, path = unpack(location)
  local bufnr = vim.fn.bufnr(path)

  if bufnr <= 0 then return end

  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum - 1 })

  if #diagnostics == 0 then return end

  for _, diagnostic in ipairs(diagnostics) do
    if col >= diagnostic.col and col <= diagnostic.end_col then
      return true
    end
  end
  return false
end

local function get_is_item_at_loc(item, location)
  local lnum, col, path = unpack(location)
  return path == vim.api.nvim_buf_get_name(item.bufnr)
    and lnum >= item.lnum and lnum <= item.end_lnum
    and col + 1 >= item.col and col + 1 < item.end_col
end

local function highlight_item_at_idx(idx, hl)
  local qfbufnr = vim.fn.getqflist{ qfbufnr = 0 }.qfbufnr
  if qfbufnr ~= 0 then
    pcall(vim.api.nvim_buf_set_extmark,
      qfbufnr,
      vim.api.nvim_create_namespace('hl_qf_idx'),
      idx - 1, 0, {
        id = 1,
        priority = 102,
        virt_text = {{ '   ', hl }},
        virt_text_pos = 'overlay',
      }
    )
  end
end

local function clear_item_highlight()
  local qfbufnr = vim.fn.getqflist{ qfbufnr = 0 }.qfbufnr
  vim.api.nvim_buf_clear_namespace(
    qfbufnr,
    vim.api.nvim_create_namespace('hl_qf_idx'),
    0, -1
  )
end

function fn.select_lsp_diagnostic(severityOrLocation)
  severityOrLocation = severityOrLocation
    or vim.api.nvim_win_get_cursor(0)

  local severity, location
  if type(severityOrLocation) == 'table' then
    severityOrLocation[3] = severityOrLocation[3]
      or vim.api.nvim_buf_get_name(0)
    location = severityOrLocation
  else
    severity = severityOrLocation
  end

  local list = vim.fn.getqflist {
    id = qf_info['lsp_diagnostics'],
    context = 0,
    idx = 0,
    items = 0,
  }

  if vim.deep_equal(severityOrLocation, list.context.selection) then
    if is_current_qf(list.context.name) then
      local sel_item =  list.items[list.idx]
      if sel_item then
        local _, hl = fn.get_sign_for_severity(sel_item.type)
        highlight_item_at_idx(list.idx, hl)
      end
    end
  elseif severity or get_has_diagnostic_at_loc(location) then
    local start
    for idx, item in ipairs(list.items) do
      if #item.type > 0 then
        start = start or idx

        if (location and get_is_item_at_loc(item, location))
            or severity
        then
          local sign, hl = fn.get_sign_for_severity(item.type)
          if vim.deep_equal({ sign, hl }, { fn.get_sign_for_severity(severity) })
              or location
          then
            set_qf_list(list.context.name, {
              context = { selection = severityOrLocation },
              idx = idx,
            })

            if is_current_qf(list.context.name)
                and item.bufnr ~= 0
            then
              vim.schedule(function()
                highlight_item_at_idx(idx, hl)
              end)
            end
            break
          end
        end
      end
    end

    list = vim.fn.getqflist{
      id = list.id,
      context = 0,
      idx = 0,
      items = 0,
    }

    if type(list.context.selection) == 'table' then
      if list.idx ~= 0 and not get_is_item_at_loc(
        list.items[list.idx],
        list.context.selection
      ) then
        set_qf_list(list.context.name, {
          context = { selection = nil },
          idx = start,
        })
      end
    end
  end

  local context = get_qf_context(list.context.name)

  if type(context.selection) ~= 'table' then
    vim.schedule(clear_item_highlight)
  end
end

function fn.show_lsp_diagnostics_list(severity)
  show_qf('lsp_diagnostics', true)
  fn.select_lsp_diagnostic(severity)
end

function fn.update_lsp_diagnostics_list()
  local diag_count_max = 100
  local s = vim.diagnostic.severity
  local severities = {
    [s.ERROR] = 'E',
    [s.HINT] = 'N',
    [s.INFO] = 'I',
    [s.WARN] = 'W',
  }

  local diag_map = {}

  for severity, _ in pairs(severities) do
    local diagnostics = vim.diagnostic.get(nil, { severity = severity })

    for i = 1, #diagnostics do
      local diagnostic = diagnostics[i]

      local source_name = diagnostic.source
        and diagnostic.source:lower()
        or 'neovim'
      local source_map = diag_map[source_name]
      if not source_map then
        source_map = {}
        diag_map[source_name] = source_map
      end

      local code_key = ''..severity
      if severity == s.ERROR then
        code_key = code_key..',Errors'
      elseif severity == s.HINT or severity == s.INFO then
        local code = diagnostic.code
        local title = code and '['..code..']'
          or (severity == s.HINT and 'Hint' or 'Info')
        code_key = code_key..','..title
      elseif severity == s.WARN then
        code_key = code_key..',Warnings'
      end

      local diag_list = source_map[code_key]
      if not diag_list then
        diag_list = {}
        source_map[code_key] = diag_list
      end

      if #diag_list < diag_count_max then
        local item = vim.diagnostic.toqflist{ diagnostic }[1]
        table.insert(diag_list, get_diagnostic_line(item))

        if type(diagnostic.user_data) == 'table' then
          for _, info in ipairs(diagnostic.user_data) do
            local info_item = vim.diagnostic.toqflist{ info }[1]
            info_item.type = '>'
            table.insert(diag_list, get_diagnostic_line(info_item))
          end
        end
      elseif #diag_list == diag_count_max then
        local remaining_count = #diagnostics - diag_count_max
        if remaining_count > 0 then
          table.insert(diag_list, get_diagnostic_line{
            text = ''..remaining_count..' more items...',
            type = '.',
          })
        end
      else
        break
      end
    end
  end

  local sources = vim.tbl_keys(diag_map)
  table.sort(sources, function(a, b)
    return a < b
  end)

  local lines = {}
  for _, source_name in ipairs(sources) do
    table.insert(lines, get_diagnostic_line{
      text = source_name
        :gsub('[^A-Za-z0-9 ]', ' ')
        :gsub('(%l)(%w*)', function(a, b)
          return a:upper()..b
        end)
    })

    local source_map = diag_map[source_name]
    local code_keys = vim.tbl_keys(source_map)
    table.sort(code_keys, function (a, b)
      return a < b
    end)

    for _, code_key in ipairs(code_keys) do
      local key = vim.split(code_key, ',')
      local val = source_map[code_key]
      table.insert(lines, get_diagnostic_line{
        text = key[2],
        type = severities[tonumber(key[1])],
      })
      vim.list_extend(lines, val)
    end
  end

  set_qf_list('lsp_diagnostics', {
    efm = '%t|%l-%e:%c-%k|%o|%f|%m,%t|%l-%e:%c-%k||%f|%m,%t||||%m,||||%m',
    lines = lines
  })

  fn.select_lsp_diagnostic()
end

function fn.show_lsp_definitions_list()
  clear_item_highlight()
  show_qf('lsp_definitions')
end

function fn.update_lsp_definitions_list(options)
  options.title = nil
  set_qf_list('lsp_definitions', options)
end

function fn.show_lsp_references_list()
  clear_item_highlight()
  show_qf('lsp_references')
end

function fn.update_lsp_references_list(options)
  options.title = nil
  set_qf_list('lsp_references', options)
end

function fn.get_task_output_codes()
  local qf_name_prefix = 'task_output_'

  local codes = {}
  for _, id in ipairs(qf_info.task_output_ids) do
    local qf_name = qf_name_prefix..id
    local context = get_qf_context(qf_name)
    if context.is_running or context.exit_code then
      table.insert(codes, context.exit_code or -1)
    end
  end
  return codes
end

function fn.show_task_output(nr)
  clear_item_highlight()

  local qf_name_prefix = 'task_output_'

  local count = 0
  for _, id in ipairs(qf_info.task_output_ids) do
    local qf_name = qf_name_prefix..id
    local context = get_qf_context(qf_name)
    if context.is_running or context.exit_code then
      count = count + 1
      if count == nr then
        show_qf(qf_name)
        vim.cmd.cbottom()
        break
      end
    end
  end
end

function fn.update_task_output(output, qf_id)
  local qf_name_prefix = 'task_output_'

  if not qf_id then
    for _, id in ipairs(qf_info.task_output_ids) do
      local qf_name = qf_name_prefix..id
      local context = get_qf_context(qf_name)
      if not context.is_running then
        set_qf_list(qf_name)
        if not qf_id then
          qf_id = id
        end
      end
    end
  end

  if qf_id then
    local qf_name = qf_name_prefix..qf_id
    if type(output) == 'table' then
      local lines = {}
      for _, line in ipairs(output) do
        table.insert(lines, line)
      end
      for i = #lines, 1, -1 do
        if #vim.trim(lines[i]) == 0 then
          table.remove(lines, i)
        end
      end
      set_qf_list(qf_name, {
        context = { is_running = true },
        lines = lines,
      }, true)
      if is_current_qf(qf_name) then
        vim.cmd.cbottom()
      end
    else
      set_qf_list(qf_name, {
        context = { exit_code = output },
      })
    end
  end
  return qf_id
end

function fn.update_notifications_list(level, note)
  local time = vim.fn.strftime("%b %d %Y %H:%M:%S")
  local severities = {
    [vim.log.levels.ERROR] = 'E',
    [vim.log.levels.WARN] = 'W',
    [vim.log.levels.DEBUG] = 'N',
    [vim.log.levels.INFO] = 'I',
    [vim.log.levels.TRACE] = 'N',
  }
  local lines = {
    ('%s|%s'):format(severities[level], time),
  }
  vim.list_extend(lines, vim.tbl_map(function(line)
    return ('|%s'):format(line)
  end, vim.split(note, '\n')))

  set_qf_list('notifications', {
    efm = '|%m,%t|%m',
    lines = lines,
  }, true)
end

function fn.show_notifications_list()
  clear_item_highlight()
  show_qf('notifications')
  vim.cmd.cbottom()
end

function fn.show_messages_list()
  clear_item_highlight()
  show_qf('messages')
  vim.cmd.cbottom()
end

function fn.close_quickfix_preview()
  if qf_info.preview_win then
    vim.api.nvim_win_close(qf_info.preview_win, true)
    qf_info.preview_win = nil
  end
end

function fn.open_quickfix_preview()
  local list = vim.fn.getqflist {
    id = 0,
    items = 0,
    winid = 0,
  }
  if list.winid ~= 0 then
    local index = vim.fn.line('.', list.winid)
    local item = list.items[index]
    if item.bufnr ~= 0 then
      qf_info.preview_win = fn.popup_preview {
        context = qf_info.preview_win,
        buf = item.bufnr,
        lnum = item.lnum,
        col = item.col,
        end_col = item.end_col,
        anchor_row = -1,
        anchor_win = list.winid,
      }
    else
      fn.close_quickfix_preview()
    end
  end
end

function fn.init_quickfix()
  set_qf_list('lsp_diagnostics', { title = "LSP Diagnostics" })
  set_qf_list('lsp_definitions', { title = "LSP Definitions" })
  set_qf_list('lsp_references', { title = "LSP References" })
  set_qf_list('notifications', { title = "Notifications" })

  for _, id in ipairs(qf_info.task_output_ids) do
    set_qf_list('task_output_'..id, { title = "Task Output "..id })
  end

  set_qf_list('messages', { title = "Messages" })

  local group = vim.api.nvim_create_augroup('conf_qf', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'qf',
    callback = function()
      vim.api.nvim_create_autocmd('BufLeave', {
        buffer = 0,
        group = group,
        callback = fn.close_quickfix_preview,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = 0,
        group = group,
        callback = fn.open_quickfix_preview,
      })

      vim.api.nvim_buf_set_keymap(0, 'n', [[<Enter>]], [[]], {
        callback = function()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]
          local list = vim.fn.getqflist{ id = 0, items = 0 }
          local item = list.items[lnum]
          if item.bufnr ~= 0 then
            local win = vim.fn.win_getid(vim.fn.winnr('#'))
            vim.api.nvim_set_current_win(win)

            local path = vim.api.nvim_buf_get_name(item.bufnr)
            vim.cmd.drop(vim.fn.fnameescape(path))
            vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
          end
        end,
      })
    end,
  })
end
--}}}
--{{{ Bookmarks
function fn.get_bookmarks()
  local bookmarks = {}
  for _, mark in ipairs(vim.fn.getmarklist()) do
    local name = mark.mark:sub(2)
    local id = #name == 1 and vim.fn.char2nr(name)
    if not id or id < 65 or id > 90 then
      break
    end
    table.insert(bookmarks, {
      buf = mark.pos[1],
      name = name,
      path = mark.file,
    })
  end
  return bookmarks
end

function fn.is_bookmarked(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  for _, bookmark in ipairs(fn.get_bookmarks()) do
    if bookmark.buf == buf then
      return true
    end
  end
  return false
end

function fn.refresh_bookmark_list()
  vim.cmd.wshada{ bang = true }

  local old_showtabline = vim.o.showtabline
  vim.o.showtabline = #fn.get_bookmarks() > 0 and 2 or 0
  if vim.o.showtabline == old_showtabline and vim.o.showtabline ~= 0 then
    vim.schedule(vim.cmd.redrawtabline)
  end
end

function fn.toggle_bookmarked(bufOrName)
  local buf
  local name
  if type(bufOrName) == 'string' then
    name = bufOrName
  else
    buf = bufOrName
  end
  buf = buf or vim.api.nvim_get_current_buf()

  local names = {
    'Q', 'W', 'E', 'A', 'S', 'D', 'Z', 'X', 'C', 'R', 'F', 'V', 'T',
    'G', 'B', 'J', 'K', 'L', 'N', 'H', 'U', 'I', 'O', 'P', 'M', 'Y',
  }

  local has_toggled = false
  local new_mark_id = 1
  if name then
    has_toggled = vim.api.nvim_buf_del_mark(buf, name)
  else
    for _, bookmark in ipairs(fn.get_bookmarks()) do
      if bookmark.buf == buf then
        vim.api.nvim_del_mark(bookmark.name)
        has_toggled = true
      end
      if not has_toggled then
        local mark_id = vim.fn.index(names, bookmark.name) + 1
        if new_mark_id == mark_id then
          new_mark_id = new_mark_id + 1
        end
      end
    end
  end
  if not has_toggled and (not name or not fn.is_bookmarked(buf)) then
    local new_name = name or names[new_mark_id]
    if new_name then
      vim.api.nvim_buf_set_mark(buf, new_name, 1, 0, {})
      has_toggled = true
    end
  end

  if has_toggled then
    fn.refresh_bookmark_list()
  end
  return has_toggled
end

function fn.goto_bookmark(name)
  local is_ok, mark = pcall(vim.api.nvim_get_mark, name, {})
  if is_ok then
    local _, _, buf = unpack(mark)
    if buf ~= 0 and buf ~= vim.api.nvim_get_current_buf() then
      vim.api.nvim_win_set_buf(0, buf)
      return true
    end
  end
  return false
end
--}}}
--{{{ Navigation
function fn.move_cursor_right()
  local count = vim.v.count1
  for _ = 1, count, 1 do
		local isOnFold = vim.fn.foldclosed('.') > -1
		if isOnFold then
			pcall(vim.cmd.normal, { 'zo', bang = true })
		else
      vim.cmd.normal{ 'l', bang = true }
		end
	end
end

function fn.relative_jump(dir)
  vim.wo.relativenumber = true
  vim.schedule(function()
    local input = vim.fn.getchar()
    if type(input) == 'number'
        and input >= 49
        and input <= 57 then
      local count = vim.fn.nr2char(input)
      vim.wo.relativenumber = false
      vim.cmd.normal(count..dir)
    else
      vim.wo.relativenumber = false
    end
  end)
end

function fn.edit_buffer(mode, path)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  local target_winid
  for _, id in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(id)
    if path == vim.api.nvim_buf_get_name(buf) then
      target_winid = id
      break
    end
  end
  if target_winid == nil then
    vim.cmd[mode](path)
  else
    vim.api.nvim_set_current_win(target_winid)
  end
end

function fn.float_window()
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

function fn.close_tab(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()

  if #vim.api.nvim_list_tabpages() <= 2 then
    vim.cmd.quitall()
  else
    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tabpage))
  end
end

function fn.close_window(win)
  win = win or vim.api.nvim_get_current_win()

  local buf = vim.api.nvim_win_get_buf(win)
  if #vim.api.nvim_tabpage_list_wins(0) > 0 then
    vim.api.nvim_win_close(win, false)
  else
    require'mini.bufremove'.unshow(buf)
  end
end

function fn.zoom_window(win)
  win = win or vim.api.nvim_get_current_win()

  if require'edgy'.get_win(win) then
    local winpos
    for _, pos in ipairs{ 'bottom', 'top', 'left', 'right' } do
      for _, winid in ipairs(require'edgy.layout'.get(pos)) do
        if winid == win then
          winpos = pos
          break
        end
      end
      if winpos then break end
    end
    if winpos then
      for _, winid in ipairs(require'edgy.layout'.get(winpos)) do
        if winid ~= win then
          require'edgy'.get_win(winid):hide()
        end
      end
    end
  else
    vim.cmd.only()
  end
end

function fn.jump(dir, maps)
  local query = require'portal.builtin'.jumplist.query {
    direction = dir,
  }
  local results = require'portal'.search(query)
  local windows = require'portal'.portals(results)

  require'portal'.open(windows)

  vim.schedule(function()
    local input = vim.fn.getcharstr()
    for map, key in pairs(maps) do
      map = vim.api.nvim_replace_termcodes(map, true, false, true)
      if input:match('^'..map..'$') then
        if type(key) == 'string' then
          key = vim.api.nvim_replace_termcodes(key, true, false, true)
          vim.api.nvim_feedkeys(key, 'm', false)
        else
          key(windows[1], input)
        end
        break
      end
    end

    require'portal'.close(windows)
  end)
end

function fn.track_buf_leave_win(buf, win)
  buf = buf or vim.api.nvim_get_current_buf()
  if fn.is_file_buffer(buf) then
    win = win or vim.api.nvim_get_current_win()
    local cur = vim.api.nvim_win_get_cursor(win)
    vim.api.nvim_create_autocmd('BufEnter', {
      once = true,
      callback = function()
        if win == vim.api.nvim_get_current_win() then
          local infos = vim.fn.getbufinfo(buf)
          if #infos > 0 then
            local info = infos[1]
            if info.listed == 1 then
              local list = vim.tbl_filter(
                function(e)
                  return e.bufnr ~= 0 and e.bufnr ~= buf
                end,
                vim.fn.getloclist(win)
              )
              local name
              if vim.fn.has('win32') == 1 then
                local shellslash = vim.o.shellslash
                vim.o.shellslash = false
                name = vim.api.nvim_buf_get_name(buf)
                vim.o.shellslash = shellslash
              end
              table.insert(list, 1, {
                bufnr = buf,
                filename = name,
                col = cur[2] + 1,
                lnum = cur[1],
              })
              vim.fn.setloclist(win, list, 'r')
            end
          end
        end
      end,
    })
  end
end
--}}}
--{{{ VCS
local dir_git_info = {}

local function get_git_info(tabpageOrPath)
  local key = resolve_path(tabpageOrPath)
  local info = dir_git_info[key]
  local prev_key
  while not info do
    key = vim.fn.fnamemodify(key, ":h")
    if key == prev_key then
      break
    end
    info = dir_git_info[key]
    prev_key = key
  end
  return info
end

local function set_git_info(tabpageOrPath, info)
  local key = resolve_path(tabpageOrPath)
  local val = dir_git_info[key]
  dir_git_info[key] = info and vim.tbl_extend("force", val or {}, info)
end

local function run_git_command(tabpageOrPath, command)
  local git = ("git -C '%s'"):format(resolve_path(tabpageOrPath))
  return vim.trim(vim.fn.system(git.." "..command))
end

function fn.is_git_dir(tabpageOrPath)
  local info = get_git_info(tabpageOrPath)
  return info and (info.is_git_dir or false) or false
end

function fn.get_git_branch(tabpageOrPath)
  local info = get_git_info(tabpageOrPath)
  return info and info.branch
end

function fn.refresh_git_diff_info(tabpageOrPath)
  if fn.is_git_dir(tabpageOrPath) then
    local branch = fn.get_git_branch(tabpageOrPath)
    local remote_cmd = 'show-branch remotes/origin/'..branch
    run_git_command(tabpageOrPath, remote_cmd)
    local has_remote = vim.v.shell_error == 0
    set_git_info(tabpageOrPath, { has_remote = has_remote })
    local stash_cmd = 'rev-list --walk-reflogs --count refs/stash'
    local stash_count = tonumber(run_git_command(tabpageOrPath, stash_cmd))
    set_git_info(tabpageOrPath, {
      stash_count = vim.v.shell_error == 0 and stash_count or 0,
    })
    if has_remote then
      local count_cmd = ('rev-list --left-right --count %s@{upstream}...%s'):format(branch, branch)
      local counts = vim.split(run_git_command(tabpageOrPath, count_cmd), "\t", { trimempty = true })
      set_git_info(tabpageOrPath, {
        local_change_count = tonumber(counts[2]),
        remote_change_count = tonumber(counts[1]),
      })
    else
      local count_cmd = ("rev-list --count %s"):format(branch)
      set_git_info(tabpageOrPath, {
        local_change_count = tonumber(run_git_command(tabpageOrPath, count_cmd)),
      })
    end
  end
end

function fn.refresh_git_info(tabpageOrPath)
  local branch = run_git_command(tabpageOrPath, "branch --show-current")
  local is_git_dir = vim.v.shell_error == 0
  set_git_info(tabpageOrPath, { is_git_dir = is_git_dir })
  if is_git_dir then
    set_git_info(tabpageOrPath, { branch = branch })
    local dir = run_git_command(tabpageOrPath, "rev-parse --show-toplevel")
    set_git_info(tabpageOrPath, { dir = dir })
    fn.refresh_git_diff_info(tabpageOrPath)
  else
    set_git_info(tabpageOrPath, nil)
  end
end

function fn.get_git_dir(tabpageOrPath)
  local info = get_git_info(tabpageOrPath)
  return info and info.dir
end

function fn.has_git_remote(tabpageOrPath)
  local info = get_git_info(tabpageOrPath)
  return info and (info.has_remote or false) or false
end

function fn.git_stash_count(tabpageOrPath)
  local info = get_git_info(tabpageOrPath)
  return info and (info.stash_count or 0) or 0
end

function fn.git_local_change_count(tabpageOrPath)
  local info = get_git_info(tabpageOrPath)
  return info and (info.local_change_count or 0) or 0
end

function fn.git_remote_change_count(tabpageOrPath)
  local info = get_git_info(tabpageOrPath)
  return info and (info.remote_change_count or 0) or 0
end

function fn.get_git_worktree_root(tabpageOrPath)
  local folder = resolve_path(tabpageOrPath)
  if not fn.is_git_dir(tabpageOrPath) then
    return folder
  end
  local branch = fn.get_git_branch(tabpageOrPath)
  local branch_path = branch
  local folder_path = folder
  while true do
    local branch_part = vim.fn.fnamemodify(branch_path, ":t")
    local folder_part = vim.fn.fnamemodify(folder_path, ":t")
    if folder_part ~= branch_part then
      return folder
    end
    branch_path = vim.fn.fnamemodify(branch_path, ":h")
    folder_path = vim.fn.fnamemodify(folder_path, ":h")
    if branch_path == "." then
      return folder_path
    end
  end
end

function fn.run_git_commit(tabpageOrPath)
  run_git_command(tabpageOrPath, [[diff --quiet HEAD]])
  if vim.v.shell_error == 0 then
    vim.notify('Nothing to commit', vim.log.levels.INFO)
  else
    vim.ui.input({
        prompt = " 󰘬 Commit message: ",
        dressing = {
          relative = 'editor',
        },
      },
      function(msg)
        if msg and #msg > 0 then
          fn.ui_try(
            run_git_command,
            tabpageOrPath,
            'commit --message "'..msg..'"'
          )
          fn.refresh_git_info(tabpageOrPath)
        end
      end)
  end
end

function fn.search_git_history()
  vim.ui.input({
      prompt = " 󰘬 Search term: ",
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

function fn.open_in_os(args)
  require'plenary.job':new{
    args = args,
    command = vim.fn.has('win32') == 1 and 'explorer' or 'open',
    detached = true,
  }:start()
end

function fn.open_in_github(path)
  local remote = run_git_command(path, 'remote get-url origin')
  local repo_path = remote:sub(1, 4) == 'http'
    and remote:match[[com/(.*)%.]]
    or remote:match[[com:(.*)%.]]
  local file_path = path or vim.api.nvim_buf_get_name(0)
  local info = get_git_info(file_path)
  file_path = vim.fn.substitute(file_path, info.dir..'/', '', '')
  local url = ('https://github.com/%s/blob/%s/%s')
    :format(repo_path, info.branch, file_path)
  if not path and vim.fn.mode():sub(1, 1):lower() == 'v' then
    url = url..'#L'..vim.api.nvim_win_get_cursor(0)[1]
  end
  fn.open_in_os{ url }
end

function fn.open_git_repo(path)
  if fn.has_git_remote(path) then
    local remote = run_git_command(path, 'remote get-url origin')
    local repo_path = remote:sub(1, 4) == 'http'
      and remote:match[[com/(.*)%.]]
      or remote:match[[com:(.*)%.]]
    local file_path = path or vim.api.nvim_buf_get_name(0)
    local info = get_git_info(file_path)
    require'plenary.job':new{
      args = {
        'pr',
        'view',
        '--web',
        '--repo',
        repo_path,
        info.branch,
      },
      command = 'gh',
      detached = true,
      env = { PATH = vim.env.PATH },
      on_exit = function(_, return_val)
        if return_val ~= 0 then
          fn.vim_defer(function()
            require'plenary.job':new{
              args = {
                'repo',
                'view',
                repo_path,
                '--web',
                '--branch',
                info.branch,
              },
              command = 'gh',
              detached = true,
            }:start()
          end)()
        end
      end,
    }:start()
  end
end

function fn.show_file_history(range, term)
  require'diffview'.file_history(range, term and '-G"'..term..'"')
end
--}}}
--{{{ Assistants
function fn.ai_gen(cmd, text)
  require'gp'

  local filetype = vim.bo.filetype

  local lines = text
    and vim.split(text, '\n')
    or vim.api.nvim_buf_get_lines(0, 0, -1, false)

  vim.cmd.tabedit()

  vim.bo.filetype = 'markdown'
  vim.bo.bufhidden = 'wipe'

  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

  vim.cmd {
    cmd = 'Gp'..cmd,
    range = { 1, vim.fn.line('$') },
  }

  vim.api.nvim_create_autocmd('User', {
    once = true,
    pattern = 'GpDone',
    callback = function(event)
      vim.bo[event.buf].filetype = filetype
    end,
  })
end

function fn.ai_conv(cmd, text)
  require'gp'

  local lines = text
    and vim.split(text, '\n')
    or vim.api.nvim_buf_get_lines(0, 0, -1, false)

  vim.ui.input({
      prompt = " 󰗊 Translate to: ",
      dressing = {
        relative = text and "cursor" or "win",
      },
    },
    function(filetype)
      vim.cmd.tabedit()

      vim.bo.filetype = 'markdown'
      vim.bo.bufhidden = 'wipe'

      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

      vim.cmd {
        args = { filetype },
        cmd = 'Gp'..cmd,
        range = { 1, vim.fn.line('$') },
      }

      vim.api.nvim_create_autocmd('User', {
        once = true,
        pattern = 'GpDone',
        callback = function(event)
          vim.bo[event.buf].filetype = filetype
        end,
      })
    end)
end
--}}}
--{{{ Tasks
function fn._task_cb_runner(id)
  local cb = _G._task_cb_reg[id]
  local old_cwd = vim.fn.getcwd()
  if cb.cwd then
    vim.api.nvim_set_current_dir(cb.cwd)
  end
  local is_ok, out = pcall(cb.func, cb.args)
  if cb.cwd then
    vim.api.nvim_set_current_dir(old_cwd)
  end
  _G._task_cb_reg[id] = nil
  if not is_ok then
    error(out)
  end
  return out or ''
end

local function vim_task_def(name, args, cwd, deps, func)
  if not _G._task_cb_id then
    _G._task_cb_id = 0
    _G._task_cb_reg = {}
  end
  _G._task_cb_id = _G._task_cb_id + 1
  _G._task_cb_reg[_G._task_cb_id] = {
    args = args,
    cwd = cwd,
    func = func,
    name = name,
  }
  return {
    args = {
      '--clean',
      '--headless',
      '--server',
      vim.v.servername,
      '--remote-expr',
      'v:lua.fn._task_cb_runner('.._G._task_cb_id..')',
    },
    cmd = { vim.v.progpath },
    components = deps,
    name = name,
  }
end

function fn.create_task(name, config)
  require'overseer'.register_template {
    name = name,
    builder = function(params)
      local args = vim.list_extend(
        vim.deepcopy(config.args or {}),
        vim.deepcopy(params.args or {}))
      local deps = {
        { 'task_output_quickfix' },
        config.notify == false
          and { 'on_complete_notify', statuses = {} }
          or 'on_complete_notify',
        { 'run_after', task_names = config.deps or {} },
        'default',
      }
      if not config.func then
        return {
          args = args,
          cmd = { config.cmd },
          components = deps,
          cwd = config.cwd,
          env = config.env,
          name = name,
        }
      else
        local named_args = vim.deepcopy(params)
        named_args.args = nil
        return vim_task_def(
          name,
          vim.tbl_extend('keep', args, named_args),
          config.cwd,
          deps,
          config.func
        )
      end
    end,
    condition = {
      callback = config.cond,
      dir = fn.get_workspace_dir(),
      filetype = config.filetype,
    },
    params = vim.tbl_extend('keep', vim.deepcopy(config.params or {}), {
      args = {
        delimiter = ',',
        desc = "Task arguments",
        optional = true,
        subtype = { type = 'string' },
        type = 'list',
      },
    }),
    priority = config.priority,
  }
end

function fn.has_task(name)
  require'overseer'.preload_task_cache()
  local task_def
  require'overseer.template'.get_by_name(
    name,
    { dir = fn.get_workspace_dir() },
    function(def)
      task_def = def
    end)
  return task_def ~= nil
end

function fn.run_task(name, args)
  local params = { args = {} }
  local opts = {}
  if args then
    opts = args.opts or {}
    args.opts = nil

    for k, v in pairs(args) do
      if type(k) == 'number' then
        params.args[k] = v
      else
        params[k] = v
      end
    end
  end

  require'overseer'.run_template(vim.tbl_extend('force', opts, {
    name = name,
    params = params,
  }))
end

function fn.running_task_count()
  return #require'overseer.task_list'.list_tasks {
    status = require'overseer'.STATUS.RUNNING,
  }
end

function fn.exec_task(cmd, args, name, env, cwd)
  require'overseer'.new_task{
    args = args,
    cmd = cmd,
    cwd = cwd,
    components = {
      'task_output_quickfix',
      'default',
    },
    env = env,
    name = name,
  }:start()
end
--}}}
--{{{ Debugging
local debug_info = {
  keymaps = {},
  state = {},
  toolbar = {
    {
      [[<F9>]],
      action = [[toggle_breakpoint]],
      states = { 1, 2, 3 },
    },
    {
      [[<F5>]],
      action = [[continue]],
      icon = {
        '',
        color = 'Operator',
      },
      states = { 1 },
    },
    {
      [[<F5>]],
      action = [[continue]],
      icon = {
        '',
        color = 'Function',
      },
      states = { 2 },
    },
    {
      [[<F6>]],
      action = [[pause]],
      icon = {
        '',
        color = 'Function',
      },
      states = { 3 },
    },
    {
      [[<F10>]],
      action = [[step_over]],
      icon = {
        '',
        color = 'Function',
      },
      states = { 2 },
    },
    {
      [[<F11>]],
      action = [[step_into]],
      icon = {
        '',
        color = 'Function',
      },
      states = { 2 },
    },
    {
      [[<F23>]],
      action = [[step_out]],
      hint = '<S-F11>',
      icon = {
        '',
        color = 'Function',
      },
      states = { 2 },
    },
    {
      [[<F35>]],
      action = [[run_to_cursor]],
      hint = '<C-F11>',
      icon = {
        '',
        color = 'Operator',
      },
      states = { 2 },
    },
    {
      [[<F29>]],
      action = [[restart]],
      hint = '<C-F5>',
      icon = {
        '',
        color = 'Function',
      },
      states = { 2, 3 },
    },
    {
      [[<F12>]],
      action = nil,
      icon = {
        '󰗼',
        color = 'Special',
      },
      states = { 1 },
    },
    {
      [[<F17>]],
      action = [[terminate]],
      hint = '<S-F5>',
      icon = {
        '',
        color = 'Error',
      },
      states = { 2, 3 },
    },
  },
}

local function get_debug_state(tabpage)
  return debug_info.state[tabpage or vim.api.nvim_get_current_tabpage()] or 0
end

local function set_debug_state(tabpage, state)
  debug_info.state[tabpage or vim.api.nvim_get_current_tabpage()] = state
end

local function get_debug_callback(action, tabpage)
  local state = get_debug_state(tabpage)
  return function(_, _, mods)
    local task_name = 'Debug '..action:gsub('_', ' ')
    if fn.has_task(task_name) then
      fn.run_task(task_name, {
        mods = mods,
        state = state,
      })
    else
      require'dap'[action]()
    end
  end
end

local function get_debug_button_callback(button, tabpage)
  if type(button.action) == 'string' then
    return get_debug_callback(button.action, tabpage)
  end
  return button.action
end

local function set_debugging_keymap(lhs, callback, desc)
  local keymap = debug_info.keymaps[lhs]
  if keymap == nil then
    keymap = vim.fn.maparg(lhs, 'n', false, true)
    keymap.lhs = lhs
    debug_info.keymaps[lhs] = keymap
  end

  keymap.is_overridden = true

  vim.api.nvim_set_keymap('n', lhs, [[]], {
    callback = function()
      callback()
    end,
    desc = desc,
    noremap = true,
  })
end

local function unset_debugging_keymap(lhs)
  local keymap = debug_info.keymaps[lhs]
  if keymap and keymap.is_overridden then
    if keymap.rhs or keymap.callback then
      vim.api.nvim_set_keymap('n', keymap.lhs, keymap.rhs or [[]], {
        callback = keymap.callback,
        expr = keymap.expr,
        noremap = keymap.noremap,
        nowait = keymap.nowait,
        silent = keymap.silent,
        script = keymap.script,
      })
    else
      vim.api.nvim_del_keymap('n', keymap.lhs)
    end
    keymap.is_overridden = false
  end
end

local function unset_debugging_keymaps()
  for lhs, _ in pairs(debug_info.keymaps) do
    unset_debugging_keymap(lhs)
  end
end

function fn.select_debug_launcher(buf)
  vim.g.dap_current_config = nil

  local filetype = buf and vim.bo[buf].filetype or (
    vim.g.project_filetypes[vim.g.project_type] or
    vim.g.project_type or
    vim.bo.filetype
  )

  local configurations = require'dap'.configurations[filetype] or {}

  if vim.tbl_islist(configurations) and #configurations ~= 0 then
    require'dap.ui'.pick_if_many(
      configurations,
      "Configuration: ",
      function(item)
        return item.name
      end,
      function(config)
        vim.g.dap_current_config = config
      end
    )
  end
end

function fn.is_debug_mode(tabpage)
  return get_debug_state(tabpage) ~= 0
end

function fn.is_debugging(tabpage)
  return get_debug_state(tabpage) == 3
end

function fn.stop_debugging(tabpage)
  if get_debug_state(tabpage) ~= 0 then
    unset_debugging_keymaps()
    set_debug_state(tabpage, 0)

    debug_info.keymaps = {}
  end

  require'dap'.clear_breakpoints()

  require'dap'.listeners.after.event_continued.my_debug_event = nil
  require'dap'.listeners.after.continue.my_debug_event = nil
  require'dap'.listeners.after.attach.my_debug_event = nil
  require'dap'.listeners.after.launch.my_debug_event = nil
  require'dap'.listeners.after.event_stopped.my_debug_event = nil
  require'dap'.listeners.after.event_exited.my_debug_event = nil
  require'dap'.listeners.after.event_terminated.my_debug_event = nil
  require'dap'.listeners.after.disconnect.my_debug_event = nil
  require'dap'.listeners.after.terminate.my_debug_event = nil

  require'dapui'.close()

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_win_set_option(win, 'numberwidth',
      vim.api.nvim_win_get_option(win, 'numberwidth'))
  end
end

local function update_debugging_state(state, tabpage)
  if state > 0 then
    set_debug_state(tabpage, state)
    unset_debugging_keymaps()

    for _, button in ipairs(debug_info.toolbar) do
      if vim.tbl_contains(button.states, state) then
        local callback = get_debug_button_callback(button, tabpage)
          or fn.stop_debugging
        set_debugging_keymap(button[1], callback)
      end
    end
  end
end

function fn.resume_debugging(tabpage)
  local state = get_debug_state(tabpage)

  if state == 0 then
    require'dapui'.close()
    update_debugging_state(1)
  end

  require'dap'.listeners.after.event_continued.my_debug_event = function()
    require'dapui'.close()
    update_debugging_state(3)
  end
  require'dap'.listeners.after.event_process.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.attach.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.continue.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.launch.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event

  require'dap'.listeners.after.event_stopped.my_debug_event = function()
    require'dapui'.open()
    update_debugging_state(2)
  end

  require'dap'.listeners.after.event_terminated.my_debug_event = function()
    require'dapui'.close()
    update_debugging_state(1)
  end
  require'dap'.listeners.after.event_exited.my_debug_event =
    require'dap'.listeners.after.event_terminated.my_debug_event
  require'dap'.listeners.after.disconnect.my_debug_event =
    require'dap'.listeners.after.event_terminated.my_debug_event
  require'dap'.listeners.after.terminate.my_debug_event =
    require'dap'.listeners.after.event_terminated.my_debug_event
end

function fn.get_debug_toolbar(tabpage)
  local components = {}
  for i, button in ipairs(debug_info.toolbar) do
    if button.icon then
      table.insert(components, {
        action = button.action or ('action_'..i),
        highlight = button.icon.color,
        icon = button.icon[1],
        keymap = button.hint or button[1],
        click_cb = function(click_count, mouse_button, mods)
          local btn_cb = get_debug_button_callback(button, tabpage)
            or function() fn.stop_debugging(tabpage) end
          btn_cb(click_count, mouse_button, mods)
        end,
        cond_cb = function()
          return vim.tbl_contains(button.states, get_debug_state(tabpage))
        end,
      })
    end
  end
  return components
end

function fn.toggle_debug_repl()
  require'dap'.repl.toggle()
end

function fn.load_vscode_launch_json(path)
  local is_ok, result = pcall(require'dap.ext.vscode'.load_launchjs, path)
  if not is_ok then
    vim.notify(result, vim.log.levels.WARN)
  end
end
--}}}
--{{{ Workspace
local function get_workspace_file_path(tabpage)
  return fn.get_workspace_dir(tabpage)..'/'..vim.g.workspace_file_name
end

local function get_workspace_config_path(tabpage)
  return fn.get_workspace_dir(tabpage)..'/'..vim.g.local_config_file_name
end

local function load_workspace(tabpage)
  local workspace_file = io.open(get_workspace_file_path(tabpage), "r")
  if workspace_file ~= nil then
    fn.freeze_workspace(tabpage, false)
    local workspace_path = fn.get_workspace_dir(tabpage)
    local workspace_conf = workspace_file:read('*a')
    pcall(vim.api.nvim_exec2, workspace_conf, { output = false })
    io.close(workspace_file)
    fn.set_tab_cwd(tabpage, workspace_path)
  end
end

function fn.get_workspace_dir(tabpageOrPath)
  local current_dir = resolve_path(tabpageOrPath)
  local workspace_path = vim.fn.findfile(vim.g.workspace_file_name, current_dir..';')
  if workspace_path ~= '' then
    workspace_path = vim.fn.fnamemodify(workspace_path, ':p')
    return workspace_path:sub(1, -#vim.g.workspace_file_name - 2)
  end
  return current_dir
end

function fn.has_workspace_file(tabpage)
  return vim.fn.filereadable(get_workspace_file_path(tabpage)) == 1
end

function fn.has_workspace_config(tabpage)
  return vim.fn.filereadable(get_workspace_config_path(tabpage)) == 1
end

function fn.save_as_workspace_config(path)
  if path and #path > 0 and vim.fn.filereadable(path) == 1 then
    local workspace_path = fn.get_workspace_dir()
    local workspace_conf = workspace_path..'/'..vim.g.local_config_file_name
    create_parent_dirs(workspace_conf)
    vim.fn.writefile(vim.fn.readfile(path), workspace_conf)
    pcall(require'config-local'.trust, workspace_conf)
  end
end

function fn.is_workspace_frozen(tabpage)
  local has_var, is_workspace_frozen = pcall(
    vim.api.nvim_tabpage_get_var,
    tabpage or vim.api.nvim_get_current_tabpage(),
    "is_workspace_frozen"
  )
  return not has_var or is_workspace_frozen
end

function fn.freeze_workspace(tabpage, value)
  vim.api.nvim_tabpage_set_var(
    tabpage or vim.api.nvim_get_current_tabpage(),
    "is_workspace_frozen",
    value == nil or value
  )
end

function fn.show_workspace(tabpage, value)
  if not fn.is_workspace_frozen(tabpage) then
    local root = fn.get_workspace_dir(tabpage)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if #vim.bo[buf].buftype == 0 and vim.api.nvim_buf_is_valid(buf) then
        local name = vim.api.nvim_buf_get_name(buf)
        if fn.is_subpath(name, root) then
          vim.bo[buf].buflisted = value == nil or value
        end
      end
    end
  end
end

function fn.save_workspace(tabpage, force)
  if not fn.is_workspace_frozen(tabpage) or (force or false) then
    fn.freeze_workspace(tabpage, false)
    local save_path = get_workspace_file_path(tabpage)
    create_parent_dirs(save_path)
    vim.cmd {
      args = { save_path },
      bang = true,
      cmd = 'mksession',
      mods = { silent = true },
    }
  end
end

function fn.open_workspace(path)
  local workspace_path = fn.get_workspace_dir(path)
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local cwd = fn.get_tab_cwd(tabpage)
    if cwd == workspace_path then
      if not fn.is_workspace_frozen(tabpage) then
        vim.api.nvim_set_current_tabpage(tabpage)
        return
      end
    end
  end
  if vim.fn.isdirectory(workspace_path) == 1 then
    vim.cmd.tabnew()
    local tabpage = vim.api.nvim_get_current_tabpage()
    fn.set_tab_cwd(tabpage, workspace_path)
    load_workspace()
  end
  if vim.g.project_main
      and #vim.api.nvim_tabpage_list_wins(0) == 1
      and fn.is_empty_buffer()
      and vim.fn.filereadable(vim.g.project_main) == 1
  then
    vim.cmd.edit(vim.g.project_main)
  end
end

function fn.open_workspace_folder(path)
  fn.open_folder(fn.get_workspace_dir(path))
end
--}}}

return fn
