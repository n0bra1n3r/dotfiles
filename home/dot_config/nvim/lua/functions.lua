_G.fn = {}

-- helpers --

local function get_wins_for_buf_type(buf_type)
  return vim.fn.filter(
    vim.fn.range(1, vim.fn.winnr("$")),
    string.format("getwinvar(v:val, '&bt') == '%s'", buf_type))
end

-- shell --

function _G.fn.is_git_dir()
  vim.cmd[[silent! !git rev-parse --is-inside-work-tree]]
  return vim.v.shell_error == 0
end

function _G.fn.save_dot_files()
  vim.cmd[[AsyncRun -strip chezmoi apply --source-path "%"]]
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

function _G.fn.reload_config()
  package.loaded["functions"] = nil
  package.loaded["main"] = nil
  package.loaded["mappings"] = nil
  package.loaded["plugins"] = nil

  for key, _ in pairs(package.loaded) do
    if string.match(key, "^configs") then
      package.loaded[key] = nil
    end
  end

  vim.cmd[[silent wa]]
  vim.cmd[[silent source $MYVIMRC]]

  print "Reloaded configuration"
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
    if #vim.fn.getqflist() > 0 then
      fn.open_quickfix()
    end
  end
end

function _G.fn.close_buffer()
  local tab = vim.fn.tabpagenr()
  if tab > 1 then
    vim.cmd[[windo bwipe]]
  elseif vim.fn.winnr("$") > 1 then
    vim.cmd[[close]]
  else
    vim.cmd[[bdelete]]
  end
end

function _G.fn.highlight_cursor_text(doHighlight)
  local namespace = vim.api.nvim_create_namespace("CursorText")
  local row = vim.fn.line"."
  local col = vim.fn.col"." - 1

  vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
  if doHighlight then
    vim.cmd[[highlight CursorText gui=reverse]]
    vim.api.nvim_buf_add_highlight(
      0,
      namespace,
      "CursorText",
      row - 1,
      col,
      col + 1)
  end
end

-- auto-session --

function _G.fn.cleanup_session()
  if packer_plugins["nvim-tree.lua"] and packer_plugins["nvim-tree.lua"].loaded then
    vim.cmd[[NvimTreeClose]]
  end
end

-- bufferline --

function _G.fn.next_buffer()
  require"bufferline".cycle(1)
end

function _G.fn.prev_buffer()
  require"bufferline".cycle(-1)
end

function _G.fn.filter_buffers(bufnr)
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      return false
    end
  end
  if vim.bo[bufnr].filetype == "help" then
    return false
  end
  if vim.bo[bufnr].filetype == "qf" then
    return false
  end
  return true
end

function _G.fn.sort_buffers(buf1, buf2)
  local changed_time1 = vim.fn.str2nr(vim.fn.getbufvar(buf1.id, "changedtime"))
  local changed_time2 = vim.fn.str2nr(vim.fn.getbufvar(buf2.id, "changedtime"))
  if changed_time1 ~= nil then
    if changed_time2 ~= nil then
      return changed_time1 > changed_time2
    else
      return true
    end
  else
    if changed_time2 ~= nil then
      return false
    end
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

function _G.fn.open_git_shell()
  vim.cmd("FloatermNew "
    .."--name=git_shell "
    .."--title=git "
    .."--height=0.8 "
    .."--width=0.8 "
    .."bash --rcfile ~/.dotfiles/gitrc")

  function _G.fn.open_git_shell()
    vim.cmd[[FloatermShow git_shell]]
  end
end

function _G.fn.open_run_shell()
  local qf_wins = get_wins_for_buf_type("quickfix")

  vim.cmd[[cclose | FloatermShow run_shell]]

  if #qf_wins > 0 then
    fn.open_quickfix()
  end
end

function _G.fn.run_process(command, notify)
  local cur_win = vim.fn.winnr()

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
      autoclose = 2,
      title = "run",
      wintype = "split",
      height = math.floor(vim.o.lines / 3),
    })

  fn.open_run_shell()
  vim.api.nvim_buf_set_name(vim.fn.bufnr("%"), command)
  vim.cmd(string.format("stopinsert | exec 'normal G' | %dwincmd w", cur_win))
end

function _G.fn.run_command(command)
  local cur_win = vim.fn.winnr()
  fn.open_run_shell()
  vim.fn["floaterm#send"](0, vim.fn.visualmode(), 0, 0, 0,
    string.format("--name=run_shell \x1b[F\x1b[1;5H%s\r", command))
  vim.cmd(string.format("stopinsert | exec 'normal G' | %dwincmd w", cur_win))
end

-- AsyncTask --

function _G.fn.project_status()
  return vim.g.asynctasks_profile
end

function _G.fn.check_project()
  if not fn.get_is_job_in_progress() then
    vim.cmd[[AsyncTask project-check]]
  end
end

function _G.fn.debug_project()
  vim.cmd[[AsyncTask project-debug]]
end

function _G.fn.debug_project_continue()
  vim.cmd[[AsyncTask project-debug +debugger_addr=]]
end

function _G.fn.debug_project_step()
  local file = vim.fn.expand('%:~:.')
  local line = vim.fn.line(".")

  vim.cmd(string.format("AsyncTask project-debug +debugger_addr=`%s:%d`", file, line))
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
  vim.fn["floaterm#send"](0, vim.fn.visualmode(), 0, 0, 0, "--name=run_shell \x03")
end

function _G.fn.debug_show_symbol()
  local symbol = vim.fn.expand("<cword>")

  vim.cmd(string.format("AsyncTask debug-show_symbol +debugger_addr=%s", symbol))
end

function _G.fn.debug_show_symbols()
  vim.cmd[[AsyncTask debug-show_symbols]]
end

function _G.fn.debug_exit()
  fn.debug_break()
  vim.cmd[[AsyncTask debug-exit]]
end
