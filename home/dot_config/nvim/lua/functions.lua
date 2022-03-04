_G.fn = {}

-- helpers --

local function get_wins_for_buf_type(buf_type)
  return vim.fn.filter(
    vim.fn.range(1, vim.fn.winnr("$")),
    string.format("getwinvar(v:val, '&bt') == '%s'", buf_type))
end

local function pick_window(exclude)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)

  local selectable = vim.tbl_filter(function(id)
    if exclude ~= nil then
      local bufid = vim.api.nvim_win_get_buf(id)
      for option, v in pairs(exclude) do
        local ok, option_value = pcall(vim.api.nvim_buf_get_option, bufid, option)
        if ok and vim.tbl_contains(v, option_value) then
          return false
        end
      end
    end

    local win_config = vim.api.nvim_win_get_config(id)
    return win_config.focusable and not win_config.external
  end, win_ids)

  if #selectable == 0 then return -1 end
  if #selectable == 1 then return selectable[1] end

  local chars = "asdfgtv;lkjhnyqwerpoiu"

  local i = 1
  local win_opts = {}
  local win_map = {}
  local laststatus = vim.o.laststatus
  vim.o.laststatus = 2

  for _, id in ipairs(selectable) do
    local char = chars:sub(i, i)
    local ok_status, statusline = pcall(vim.api.nvim_win_get_option, id, "statusline")
    local ok_hl, winhl = pcall(vim.api.nvim_win_get_option, id, "winhl")

    win_opts[id] = {
      statusline = ok_status and statusline or "",
      winhl = ok_hl and winhl or ""
    }
    win_map[char] = id

    vim.cmd[[highlight WindowPicker guibg=NONE guifg=lightred gui=bold]]
    vim.cmd[[highlight WindowPickerNC guibg=NONE guifg=lightred gui=italic]]

    vim.api.nvim_win_set_option(id, "statusline", string.format("%%=%s%%=", char))
    vim.api.nvim_win_set_option(id, "winhl", "StatusLine:WindowPicker,StatusLineNC:WindowPickerNC")

    i = i + 1
    if i > #chars then break end
  end

  vim.cmd[[redraw]]
  local resp = vim.fn.nr2char(vim.fn.getchar()):lower()
  for _, id in ipairs(selectable) do
    for opt, value in pairs(win_opts[id]) do
      vim.api.nvim_win_set_option(id, opt, value)
    end
  end

  vim.o.laststatus = laststatus

  return win_map[resp]
end

local function send_to_floaterm(name, command)
  local success = pcall(vim.fn["floaterm#send"],
    0,
    vim.fn.visualmode(),
    0,
    0,
    0,
    string.format("--name=%s %s", name, command))
  return success
end

-- shell --

function _G.fn.is_git_dir()
  vim.cmd[[silent! !git rev-parse --is-inside-work-tree]]
  local result = vim.v.shell_error == 0

  function _G.fn.is_git_dir()
    return result
  end

  return result
end

function _G.fn.save_dot_files()
  vim.cmd[[AsyncRun -strip chezmoi apply --exclude=scripts --force --source-path "%"]]
end

-- nvim --

function _G.fn.get_map_expr(key)
  return string.format("v:count || mode(1)[0:1] == 'no' ? '%s' : 'g%s'", key, key)
end

function _G.fn.vim_defer(fn, timer)
  return function()
    if fn ~= nil then
      if type(fn) == "function" then
        vim.defer_fn(fn, timer or 0)
      else
        vim.defer_fn(function()
          vim.cmd(fn)
        end, timer or 0)
      end
    end
  end
end

function _G.fn.trim_added_whitespace()
  local saved_view = vim.fn.winsaveview()
  vim.cmd[[keepjumps '[,']s/\s\+$//e]]
  vim.fn.winrestview(saved_view)
end

function _G.fn.open_quickfix()
  local cur_win = vim.fn.winnr()
  local term_wins = get_wins_for_buf_type("terminal")

  if #term_wins > 0 then
    vim.cmd(string.format("%dwincmd w "
      .."| stopinsert "
      .."| vertical copen "
      .."| setlocal nonumber "
      .."| vertical resize %d", term_wins[1], vim.o.columns / 2))
  else
    vim.cmd(string.format("%dcopen "
      .."| setlocal nonumber "
      .."| wincmd J", math.min(#vim.fn.getqflist(), vim.o.lines / 3)))
  end

  vim.cmd(string.format("%dwincmd w", cur_win))
end

local is_quickfix_force_closed = false

function _G.fn.toggle_quickfix()
  if #get_wins_for_buf_type("quickfix") == 0 then
    if #vim.fn.getqflist() > 0 then
      fn.open_quickfix()
    end

    is_quickfix_force_closed = false
  else
    vim.cmd[[cclose]]

    is_quickfix_force_closed = true
  end
end

function _G.fn.show_quickfix()
  if is_quickfix_force_closed == false then
    local diagnostics = fn.get_qf_diagnostics()
    if diagnostics.error > 0 or
        diagnostics.warn > 0 or
        diagnostics.hint > 0 then
      fn.open_quickfix()
    end
  end
end

function _G.fn.close_buffer()
  if vim.fn.tabpagenr() > 1 then
    vim.cmd[[windo bwipeout]]
  elseif vim.fn.winnr("$") > 1 then
    vim.cmd[[close]]
  else
    vim.cmd[[bwipeout]]
  end
end

function _G.fn.edit_file(mode, path)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)

  local target_winid

  local found = false
  for _, id in ipairs(win_ids) do
    if path == vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(id)) then
      found = true
      target_winid = id
      break
    end
  end

  if target_winid == nil then
    local exclude = {
      filetype = {
        "NvimTree",
        "packer",
        "qf",
        "floaterm",
      },
      buftype = {
        "terminal",
      },
    }
    vim.api.nvim_set_current_win(pick_window(exclude))
    vim.cmd(string.format("%s %s", mode, path))
  else
    vim.api.nvim_set_current_win(target_winid)
  end
end

function _G.fn.choose_window()
  vim.api.nvim_set_current_win(pick_window())
end

function _G.fn.set_shell_title()
  if #vim.bo.buftype == 0 then
    local file_name = vim.fn.expand("%:t")

    if #file_name > 0 then
      vim.o.titlestring = "nvim - "..file_name
    end
  end
end

function _G.fn.cleanup_window_if_needed()
  local win_config = vim.api.nvim_win_get_config(0)

  if win_config.relative ~= "" then
    if vim.bo.filetype == "floaterm" then
      vim.cmd[[FloatermHide]]
    end
  end
end

-- auto-session --

function _G.fn.cleanup_session()
  if packer_plugins["nvim-tree.lua"] and packer_plugins["nvim-tree.lua"].loaded then
    vim.cmd[[NvimTreeClose]]
  end
end

-- cmp --

local prev_line

function _G.fn.trigger_completion()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2]

  local before_line = string.sub(line, 1, cursor + 1)
  local after_line = string.sub(line, cursor + 1, -1)

  if prev_line == nil or #prev_line < #before_line then
    if string.len(after_line) == 0 and (
      string.match(before_line, "[%w%.]%w$") or
      string.match(before_line, "[%.]$")) then
      require"cmp".complete()
    else
      require"cmp".close()
    end
  else
    require"cmp".close()
  end

  prev_line = before_line
end

function _G.fn.end_completion()
  require"cmp".close()
end

-- lualine --

function _G.fn.get_qf_diagnostics()
  local error_count = 0
  local hint_count = 0
  local warn_count = 0
  for _, value in ipairs(vim.fn.getqflist()) do
    if value.type == "E" then
      error_count = error_count + 1
    elseif value.type == "N" then
      hint_count = hint_count + 1
    elseif value.type == "W" then
      warn_count = warn_count + 1
    end
  end
  return { error = error_count, hint = hint_count, warn = warn_count }
end

function _G.fn.get_project_dir()
  local folder = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")
  local bufnr = vim.api.nvim_get_current_buf()
  local branch = require"lualine.components.branch.git_branch".get_branch(bufnr)

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

local is_job_in_progress = false

function _G.fn.get_is_job_in_progress()
  return is_job_in_progress
end

function _G.fn.set_is_job_in_progress(value)
  is_job_in_progress = value
  vim.cmd[[redrawtabline]]
end

-- packer --

function _G.fn.get_config(module)
  return "require'configs."..module.."'.config()"
end

function _G.fn.get_setup(module)
  return "require'configs."..module.."'.setup()"
end

function _G.fn.lazy_load(plugin, timer)
  return function()
    fn.vim_defer(function()
      require"packer".loader(plugin)
    end, timer)
  end
end

function _G.fn.define_use(packer_use)
  return function(opts)
    local plugin = opts[1]
    local config = vim.fn.fnamemodify(plugin, ":t:r")

    local hasConfig, module = pcall(require, "configs."..config)
    if hasConfig then
      if module.setup ~= nil and opts.setup == nil then
        opts.setup = fn.get_setup(config)
      end
      if module.config ~= nil and opts.config == nil then
        opts.config = fn.get_config(config)
      end
    end

    return packer_use(opts)
  end
end

-- telescope --

function _G.fn.show_string_search_picker()
  show_picker("live_grep")
end

function show_picker(name, opts)
  local telescope_pickers = require"telescope.state".get_global_key("cached_pickers")

  local picker_index = -1

  if telescope_pickers ~= nil then
    for index, picker in ipairs(telescope_pickers) do
      if picker.cache_picker.name == name then
        picker_index = index
        break
      end
    end
  end

  local opts = opts or {}

  if picker_index == -1 then
    opts.cache_picker = {}
    opts.cache_picker.name = name
    require"telescope.builtin"[name](opts)
  else
    require"telescope.builtin".resume({ cache_index = picker_index })
  end
end

-- floaterm --

function _G.fn.open_git_shell(command)
  vim.fn["floaterm#new"](0,
    "bash --rcfile ~/.dotfiles/gitrc",
    { [''] = '' },
    {
      silent = 1,
      name = "git_shell",
      title = " "..vim.b.gitsigns_status_dict.head,
      height = math.ceil(vim.o.lines * 0.8),
      width = math.ceil(vim.o.columns * 0.8),
    })

  if command ~= nil then
    vim.cmd(string.format('set ssl | exec "FloatermSend --name=git_shell %s" | set nossl', command))
  end

  vim.cmd[[FloatermShow git_shell]]

  function _G.fn.open_git_shell(command)
    if command ~= nil then
      vim.cmd(string.format('set ssl | exec "FloatermSend --name=git_shell %s" | set nossl', command))
    end

    vim.cmd[[FloatermShow git_shell]]
  end
end

function _G.fn.open_run_shell()
  local qf_wins = get_wins_for_buf_type("quickfix")

  vim.cmd[[cclose]]
  local success = pcall(vim.fn["floaterm#show"], 0, 0, "run_shell")

  if #qf_wins > 0 then
    fn.open_quickfix()
  end

  return success
end

function _G.fn.run_process(command, notify)
  vim.fn["floaterm#new"](0,
    command,
    {
      on_exit = function()
        vim.cmd(notify)
      end,
    },
    {
      silent = 1,
      name = "run_shell",
      title = "run",
      wintype = "split",
      height = math.floor(vim.o.lines / 3),
    })

  if fn.open_run_shell() then
    vim.api.nvim_buf_set_name(0, command)
    vim.cmd(string.format("stopinsert | exec 'normal G' | %dwincmd w", vim.fn.winnr()))
  end
end

function _G.fn.run_command(command)
  if fn.open_run_shell() then
    send_to_floaterm("run_shell", string.format("\x1b[F\x1b[1;5H%s\r", command))
    vim.cmd(string.format("stopinsert | exec 'normal G' | %dwincmd w", vim.fn.winnr()))
  end
end

-- AsyncTask --

function _G.fn.project_status()
  return vim.g.asynctasks_profile
end

function _G.fn.project_check()
  if not fn.get_is_job_in_progress() then
    vim.cmd[[AsyncTask project-check]]
  end
end

function _G.fn.project_build()
  vim.cmd[[AsyncTask project-build]]
end

function _G.fn.project_test()
  vim.cmd[[AsyncTask project-test]]
end

function _G.fn.project_run()
  vim.cmd[[AsyncTask project-run]]
end

function _G.fn.project_debug()
  if fn.project_status() == "debug" then
    if fn.debug_break() then
      vim.cmd[[AsyncTask debug-restart]]
    else
      vim.cmd[[AsyncTaskProfile project]]
      local success = pcall(vim.fn["floaterm#kill"], 0, 0, "run_shell")
      vim.cmd[[AsyncTask project-debug]]
    end
  else
    vim.cmd[[AsyncTask project-debug]]
  end
end

function _G.fn.project_build_and_run()
  vim.cmd[[AsyncTask project-build_and_run]]
end

function _G.fn.project_build_and_debug()
  vim.cmd[[AsyncTask project-build_and_debug]]
end

function _G.fn.debug_continue()
  vim.cmd[[AsyncTask debug-step +debugger_addr=]]
end

function _G.fn.debug_step()
  if vim.bo.buftype == "terminal" then
    local expr = vim.fn.getline(".")
    local addr = {select(3, string.find(expr, "([%w_]+![%w_]+%+%w+)"))}

    vim.cmd(string.format("AsyncTask debug-step +debugger_addr=%s", addr[1]))
  else
    local file = vim.fn.expand('%:~:.')
    local line = vim.fn.line(".")

    vim.cmd(string.format("AsyncTask debug-step +debugger_addr=`%s:%d`", file, line))
  end
end

function _G.fn.debug_break()
  return send_to_floaterm("run_shell", "\x03")
end

function _G.fn.debug_show_symbol()
  local symbol = vim.fn.expand("<cword>")

  vim.cmd(string.format("AsyncTask debug-show_symbol +debugger_addr=%s", symbol))
end

function _G.fn.debug_show_symbols()
  vim.cmd[[AsyncTask debug-show_symbols]]
end

function _G.fn.debug_exit()
  if fn.debug_break() then
    vim.cmd[[AsyncTask debug-exit]]
  else
    local success = pcall(vim.fn["floaterm#kill"], 0, 0, "run_shell")
    vim.cmd[[AsyncTaskProfile project]]
  end
end
