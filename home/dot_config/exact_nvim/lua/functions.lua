-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function get_tab_cwd(tabnr)
  return tabnr and vim.fn.getcwd(-1, tabnr) or vim.fn.getcwd(-1)
end

local function create_parent_dirs(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.cmd(("silent !bash -c 'mkdir -p \"%s\"'"):format(dir))
  end
end
--}}}
--{{{ IPC
local ipc_info = {
  child = {},
  parent = {
    child_info = {},
    jobs = {},
  },
}

local function remote_nvim(pipe, cmd_type, cmd)
  local job = require'plenary.job':new {
    args = {
      "--clean",
      "--headless",
      "--server",
      pipe,
      "--remote-"..cmd_type,
      cmd,
    },
    command = vim.v.progpath,
    detached = true,
  }
  job:start()
  return job
end

function fn.on_child_nvim_enter(id, parent)
  local expr = ([[v:lua.fn.on_parent_nvim_enter('%s', '%s')]])
                  :format(vim.v.servername, id)
  ipc_info.child.job = remote_nvim(parent, "expr", expr)
end

function fn.on_child_nvim_exit(id, parent)
  local expr = ([[v:lua.fn.on_parent_nvim_exit('%s')]])
                  :format(id)
  ipc_info.child.job = remote_nvim(parent, "expr", expr)
end

function fn.on_parent_nvim_enter(child, id)
  local info = ipc_info.parent.child_info[id]
  if info ~= nil then
    if info.on_enter ~= nil then
      info.on_enter(child)
    end
  else
    info = {}
    ipc_info.parent.child_info[id] = info
  end
  info.pipe = child
end

function fn.on_parent_nvim_exit(id)
  local info = ipc_info.parent.child_info[id]
  if info ~= nil and info.on_exit ~= nil then
    info.on_exit()
  end
  ipc_info.parent.child_info[id] = nil
end

function fn.spawn_child(id, opts, callbacks)
  local child_id = id
  if child_id == nil then
    local sec, usec = vim.loop.gettimeofday()
    child_id = tostring(sec * 1000000 + usec)
  end
  ipc_info.parent.child_info[child_id] = callbacks or {}
  local job = require'plenary.job':new {
    command = vim.fn.expand(vim.env.EMU),
    env = {
      ["PARENT_NVIM"] = vim.v.servername,
      ["NVIM_CHILD_ID"] = child_id,
    },
    args = {
      vim.env.EMU_CMD,
      ([["%s" %s]]):format(vim.v.progpath, opts),
    },
  }
  table.insert(ipc_info.parent.jobs, job)
  job:start()
end

function fn.send_child(child, cmd_type, cmd)
  local job = remote_nvim(child, cmd_type, cmd)
  table.insert(ipc_info.parent.jobs, job)
end

function fn.get_child(id)
  return ipc_info.parent.child_info[id] and
          ipc_info.parent.child_info[id].pipe
end

function fn.is_child_alive(id)
  local child = fn.get_child(id)
  if child ~= nil then
    local result = vim.fn.system {
      vim.v.progpath,
      "--clean",
      "--headless",
      "--server",
      child,
      "--remote-expr",
      "v:version",
    }
    if vim.v.shell_error == 0 and #vim.trim(result) ~= 0 then
      return true
    end
  end
  return false
end
--}}}
--{{{ Diagnostics
  function fn.get_qf_diagnostics()
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

  function fn.set_qf_diagnostics()
    local namespace = vim.api.nvim_create_namespace("qf-diagnostics")
    local buf_diagnostics = {}

    for _, diagnostic in ipairs(vim.diagnostic.fromqflist(vim.fn.getqflist())) do
      local buf_key = diagnostic.bufnr

      if buf_diagnostics[buf_key] == nil then
        buf_diagnostics[buf_key] = {}
      end

      table.insert(buf_diagnostics[buf_key], diagnostic)
    end

    vim.diagnostic.reset(namespace)

    for buf_key, diagnostics in pairs(buf_diagnostics) do
      vim.diagnostic.set(namespace, buf_key, diagnostics)
    end
  end
--}}}
--{{{ Git
local dir_git_info = {}

local function get_git_info(tabnr)
  return dir_git_info[get_tab_cwd(tabnr)]
end

local function set_git_info(tabnr, info)
  local key = get_tab_cwd(tabnr)
  local val = dir_git_info[key]
  dir_git_info[key] = info and vim.tbl_extend("force", val or {}, info)
end

local function run_git_command(tabnr, command)
  local git = string.format("git -C '%s' ", get_tab_cwd(tabnr))
  return vim.trim(vim.fn.system(git..command))
end

function fn.is_git_dir(tabnr)
  local info = get_git_info(tabnr)
  return info and (info.is_git_dir or false) or false
end

function fn.get_git_branch(tabnr)
  local info = get_git_info(tabnr)
  return info and info.branch
end

function fn.refresh_git_diff_info(tabnr)
  if fn.is_git_dir(tabnr) then
    local branch = fn.get_git_branch(tabnr)
    local command = string.format("rev-list --left-right --count %s@{upstream}...%s", branch, branch)
    local results = vim.split(run_git_command(tabnr, command), "\t", { trimempty = true })
    local has_remote = vim.v.shell_error == 0
    set_git_info(tabnr, { has_remote = has_remote })
    if has_remote then
      set_git_info(tabnr, {
        local_change_count = tonumber(results[2]),
        remote_change_count = tonumber(results[1]),
      })
    else
      command = string.format("rev-list --count %s", branch)
      results = run_git_command(tabnr, command)
      set_git_info(tabnr, { local_change_count = tonumber(results) })
    end
  end
end

function fn.refresh_git_info(tabnr)
  local branch = run_git_command(tabnr, "branch --show-current")
  local is_git_dir = vim.v.shell_error == 0
  set_git_info(tabnr, { is_git_dir = is_git_dir })
  if is_git_dir then
    set_git_info(tabnr, { branch = branch })
    local dir = run_git_command(tabnr, "rev-parse --show-toplevel")
    set_git_info(tabnr, { dir = dir })
    fn.refresh_git_diff_info(tabnr)
  else
    set_git_info(tabnr, nil)
  end
end

function fn.get_git_dir(tabnr)
  local info = get_git_info(tabnr)
  return info and info.dir
end

function fn.has_git_remote(tabnr)
  local info = get_git_info(tabnr)
  return info and (info.has_remote or false) or false
end

function fn.git_local_change_count(tabnr)
  local info = get_git_info(tabnr)
  return info and (info.local_change_count or 0) or 0
end

function fn.git_remote_change_count(tabnr)
  local info = get_git_info(tabnr)
  return info and (info.remote_change_count or 0) or 0
end

function fn.get_git_worktree_root(tabnr)
  local folder = get_tab_cwd(tabnr)
  if not fn.is_git_dir(tabnr) then
    return folder
  end
  local branch = fn.get_git_branch(tabnr)
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
--}}}
--{{{ Files
function fn.get_open_files()
  local files = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and #vim.api.nvim_buf_get_option(buf, "buftype") == 0 then
      table.insert(files, vim.api.nvim_buf_get_name(buf))
    end
  end
  return files
end

function fn.delete_file()
  vim.fn.delete(vim.fn.expand('%:p'))
  require'mini.bufremove'.wipeout()
end

function fn.edit_file()
  local rel_dir = vim.fn.expand("%:~:.:h")
  local path = vim.fn.input("  Edit at: ", rel_dir.."/", "dir")
  if #path == 0 or path == rel_dir or path.."/" == rel_dir then
    return
  end
  create_parent_dirs(path)
  vim.cmd("edit "..vim.fn.fnameescape(path))
end

function fn.move_file()
  local rel_file = vim.fn.expand("%:~:.")
  local path = vim.fn.input("  Move to: ", rel_file, "file")
  if #path == 0 or path == rel_file then
    return
  end
  create_parent_dirs(path)
  vim.cmd(("saveas %s | call delete(expand('#')) | bwipeout #"):format(vim.fn.fnameescape(path)))
end

function fn.save_file()
  if not fn.is_empty_buffer() then
    vim.cmd[[silent update]]
    return
  end
  local rel_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")
  local path = vim.fn.input("  Save to: ", rel_dir.."/", "dir")
  if #path == 0 or path == rel_dir or path.."/" == rel_dir then
    return
  end
  create_parent_dirs(path)
  vim.cmd("saveas "..vim.fn.fnameescape(path))
end

function fn.open_file_folder()
  local shellslash = vim.o.shellslash
  vim.o.shellslash = false
  local folder = vim.fn.expand"%:p:h"
  vim.o.shellslash = shellslash
  local job = require'plenary.job':new {
    args = { folder },
    command = vim.fn.has"win32" and "explorer" or "open",
    detached = true,
  }
  job:start()
end
--}}}
--{{{ Jobs
local job_info = {
  count = 0,
  queue = {},
  progress_icons = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  progress_index = 0,
}

function fn.get_is_job_in_progress()
  return job_info.count > 0
end

function fn.set_is_job_in_progress(value)
  if value then
    job_info.count = job_info.count + 1
  else
    job_info.count = math.max(job_info.count - 1, 0)
  end
end

function fn.job_indicator()
  if job_info.progress_index == 0 then
    job_info.progress_index = 1
    local timer = vim.loop.new_timer()
    timer:start(0, vim.o.updatetime, function()
      job_info.progress_index =
        job_info.progress_index %
        #job_info.progress_icons + 1
    end)
  end
  return job_info.progress_icons[job_info.progress_index]
end

function fn.project_status()
  return vim.g.asynctasks_profile
end

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("queued_job_runner", { clear = true }),
  pattern = "AsyncRunStop",
  callback = function()
    local job
    for e, k in pairs(job_info.queue) do
      job = { kind = k, exec = e }
      break
    end
    if job ~= nil then
      job_info.queue[job.exec] = nil
      if job.kind == "task" then
        vim.cmd("AsyncTask "..job.exec)
      elseif job.kind == "command" then
        vim.cmd("AsyncRun "..job.exec)
      end
    end
  end,
})

function fn.run_task(task)
  if not fn.get_is_job_in_progress() then
    vim.cmd("AsyncTask "..task)
  else
    job_info.queue[task] = "task"
  end
end

function fn.run_command(command)
  if not fn.get_is_job_in_progress() then
    vim.cmd("AsyncRun "..command)
  else
    job_info.queue[command] = "command"
  end
end

function fn.project_check()
  local filename = vim.api.nvim_buf_get_name(0)
  fn.run_task(("project-check +file=\"%s\""):format(filename))
end
--}}}
--{{{ LSP
local function preview_location_callback(_, result, ctx)
  if result == nil or vim.tbl_isempty(result) then
    vim.lsp.log.info(ctx, "No location found")
    return nil
  end
  if vim.tbl_islist(result) then
    vim.lsp.util.preview_location(result[1])
  else
    vim.lsp.util.preview_location(result)
  end
end

function fn.peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
end

local completion_prev_line
function fn.trigger_completion()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2]
  local before_line = line:sub(1, cursor + 1)
  local after_line = line:sub(cursor + 1, -1)
  if completion_prev_line == nil or #completion_prev_line < #before_line then
    if #after_line == 0 and (
      before_line:match("[%w%.]%w$") or
      before_line:match("[%.]$")) then
      require'cmp'.complete()
    else
      require'cmp'.close()
    end
  else
    require'cmp'.close()
  end
  completion_prev_line = before_line
end

function fn.end_completion()
  require'cmp'.close()
end
--}}}
--{{{ Navigation
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

  if #selectable == 0 then
    return -1
  end
  if #selectable == 1 then
    return selectable[1]
  end

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

    vim.api.nvim_win_set_option(id, "statusline", string.format("%%=易%s%%=", char))
    vim.api.nvim_win_set_option(id, "winhl", "StatusLine:Identifier,StatusLineNC:Identifier")

    i = i + 1
    if i > #chars then
      break
    end
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

function fn.edit_buffer(mode, path)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)
  local target_winid
  for _, id in ipairs(win_ids) do
    if path == vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(id)) then
      target_winid = id
      break
    end
  end
  if target_winid == nil then
    local exclude = {
      filetype = {
        "lazy",
        "qf",
      },
      buftype = {
        "terminal",
      },
    }
    target_winid = pick_window(exclude)
    if target_winid ~= -1 then
      vim.api.nvim_set_current_win(target_winid)
    end
    vim.cmd(string.format("%s %s", mode, path))
  else
    vim.api.nvim_set_current_win(target_winid)
  end
end

function fn.choose_window()
  local picked = pick_window()
  if picked ~= nil then
    vim.api.nvim_set_current_win(picked)
  end
end

function fn.switch_prior_tab()
  local tabnr = vim.fn.tabpagenr[[#]]
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.api.nvim_tabpage_get_number(tabpage) == tabnr then
      vim.api.nvim_set_current_tabpage(tabpage)
      break
    end
  end
end

function fn.close_buffer()
  if #vim.api.nvim_tabpage_list_wins(0) > 0 then
    vim.cmd[[close]]
  else
    require'mini.bufremove'.unshow()
  end
end

function fn.open_help(word)
  word = word or vim.fn.expand[[<cword>]]
  if vim.env.EMU ~= nil then
    if not fn.is_child_alive"help" then
      fn.spawn_child("help", ([[-mMR +"HelpModeStart %s"]]):format(word))
    else
      fn.send_child(fn.get_child"help", "send", ([[<cmd>h %s<CR>]]):format(word))
    end
  else
    vim.cmd("help "..word)
  end
end
--}}}
--{{{ Quickfix
local function open_quickfix()
  vim.cmd(string.format("%dcopen "
    .."| setlocal nonumber "
    .."| wincmd J", math.min(#vim.fn.getqflist(), vim.o.lines / 6)))
end

local function close_quickfix()
  vim.cmd[[cclose]]
end

function fn.is_quickfix_visible()
  return #fn.get_wins_for_buf_type("quickfix") > 0
end

function fn.toggle_quickfix()
  if not fn.is_quickfix_visible() then
    if #vim.fn.getqflist() > 0 then
      open_quickfix()
    end
  else
    close_quickfix()
  end
end

function fn.show_quickfix()
  local diagnostics = fn.get_qf_diagnostics()
  if diagnostics.error > 0 or
      diagnostics.warn > 0 or
      diagnostics.hint > 0 then
    open_quickfix()
  end
end

function fn.hide_quickfix()
  close_quickfix()
end

function fn.next_quickfix()
  open_quickfix()
  vim.cmd[[cnext]]
end

function fn.prev_quickfix()
  open_quickfix()
  vim.cmd[[cprev]]
end
--}}}
--{{{ Terminal
local function get_terminal()
  return require'toggleterm.terminal'.Terminal:new{
    id = 0,
    cmd = "bash --login",
    direction = "tab",
  }
end

function fn.open_terminal()
  local terminal = require'toggleterm.terminal'.get(0, true)
  if terminal == nil then
    get_terminal():open()
    fn.freeze_workspace()
  else
    local tabpage = vim.api.nvim_win_get_tabpage(terminal.window)
    if vim.api.nvim_get_current_tabpage() ~= tabpage then
      vim.api.nvim_set_current_tabpage(tabpage)
    end
  end
end

function fn.dismiss_terminal()
  local terminal = require'toggleterm.terminal'.get(0, true)
  if terminal ~= nil then
    local tabpage = vim.api.nvim_win_get_tabpage(terminal.window)
    if vim.api.nvim_get_current_tabpage() == tabpage then
      fn.switch_prior_tab()
    end
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
  fn.open_terminal()
  get_terminal().dir = cwd
  fn.set_tab_cwd(cwd)
end

function fn.send_terminal(command)
  get_terminal():send(" "..command, false)
end

function fn.execute_last_terminal_command()
  fn.send_terminal[[!!]]
  fn.open_terminal()
end

function fn.sync_terminal()
  local terminal = get_terminal()
  if terminal.window ~= nil then
    local tabpage = vim.api.nvim_win_get_tabpage(terminal.window)
    if vim.api.nvim_get_current_tabpage() == tabpage then
      local cwd = vim.fn.getcwd(-1, vim.fn.tabpagenr[[#]])
      if terminal.dir ~= cwd then
        fn.send_terminal("cd "..cwd)
      end
    end
  end
end
--}}}
--{{{ Utilities
function fn.expand_each(list)
  local result = {}
  for _, item in ipairs(list) do
    table.insert(result, vim.fn.expand(item))
  end
  return vim.fn.join(result)
end

function fn.is_empty_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  local lines = vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false)
  return name == ""
    and #lines == 0
    or (#lines == 1 and lines[1] == "")
end

function fn.is_file_buffer(buf)
  return #vim.bo[buf].buftype == 0 and not fn.is_empty_buffer(buf)
end

function fn.did_cwd_change()
  return vim.fn.getcwd(-1) ~= vim.fn.getcwd(-1, vim.fn.tabpagenr[[#]])
end

function fn.get_map_expr(key)
  return string.format("(v:count!=0||mode(1)[0:1]=='no'?'%s':'g%s')", key, key)
end
function fn.get_map_expr_i(key)
  return string.format("(v:count!=0||mode(1)[0:1]=='no'?'%s':'<C-o>g%s')", key, key)
end

function fn.get_wins_for_buf_type(buf_type)
  return vim.fn.filter(
    vim.fn.range(1, vim.fn.winnr("$")),
    string.format("getwinvar(v:val, '&bt') == '%s'", buf_type))
end

function fn.vim_defer(fn, timer)
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

function fn.is_subpath(path, other)
    local path_parts = vim.split(path, "/")
    local other_parts = vim.split(other, "/")
    local common_parts = vim.list_slice(path_parts, 1, #other_parts)
    return vim.deep_equal(common_parts, other_parts)
end

function fn.set_tab_cwd(path)
  if vim.fn.getcwd(-1) ~= path then
    vim.cmd("silent tcd "..vim.fn.fnameescape(path))
  end
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

function fn.url_encode(str)
  if not str then
    return str
  end

  str = string.gsub(str, "\n", "\r\n")
  str = string.gsub(str, "[^%w.%-_~]", function(c)
    return ("%%%02X"):format(string.byte(c))
  end)

  return str
end
--}}}
--{{{ Workspace
function get_workspace_file_path(tabnr)
  return fn.get_workspace_dir(tabnr).."/"..vim.g.workspace_file_name
end

function get_workspace_file(tabnr)
  return io.open(get_workspace_file_path(tabnr), "r")
end

function fn.has_workspace_file(tabnr)
  local workspace_file = get_workspace_file(tabnr)
  local has_workspace_file = workspace_file ~= nil
  if has_workspace_file then
    io.close(workspace_file)
  end
  return has_workspace_file
end

function fn.get_workspace_dir(tabnr)
  if fn.is_git_dir(tabnr) then
    return fn.get_git_dir(tabnr)
  else
    return get_tab_cwd(tabnr)
  end
end

function fn.is_workspace_frozen(tabnr)
  if tabnr == nil then
    return vim.t.is_workspace_frozen or false
  end
  return vim.fn.gettabvar(tabnr, "is_workspace_frozen", false)
end

function fn.freeze_workspace(tabnr, value)
  local new_value = value == nil or value
  if tabnr == nil then
    vim.t.is_workspace_frozen = new_value
  else
    vim.fn.settabvar(tabnr, "is_workspace_frozen", new_value)
  end
end

function fn.show_workspace(tabnr, value)
  if not fn.is_workspace_frozen(tabnr) then
    local root = fn.get_workspace_dir(tabnr)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) then
        local name = vim.api.nvim_buf_get_name(buf)
        if fn.is_subpath(name, root) then
          vim.bo[buf].buflisted = value == nil or value
        end
      end
    end
  end
end

function fn.save_workspace(tabnr, force)
  if (vim.env.PARENT_NVIM == nil and
      not fn.is_workspace_frozen(tabnr))
      or (force or false) then
    fn.freeze_workspace(tabnr, false)
    local save_path = get_workspace_file_path(tabnr)
    create_parent_dirs(save_path)
    vim.cmd("silent mksession! "..vim.fn.fnameescape(save_path))
  end
end

function fn.load_workspace(tabnr)
  if not fn.is_workspace_frozen(tabnr) then
    local workspace_file = get_workspace_file(tabnr)
    if workspace_file ~= nil then
      fn.freeze_workspace(tabnr, false)
      local work_dir = fn.get_workspace_dir(tabnr)
      local workspace = workspace_file:read("*a")
      vim.api.nvim_exec2(workspace, { output = false })
      io.close(workspace_file)
      fn.set_tab_cwd(work_dir)
    end
  end
end

function fn.open_workspace(path)
  local workspace_path = vim.fn.expand(path)
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
    local cwd = get_tab_cwd(tabnr)
    if cwd == workspace_path then
      if not fn.is_workspace_frozen(tabnr) then
        vim.api.nvim_set_current_tabpage(tabpage)
        return
      end
    end
  end
  if vim.fn.isdirectory(workspace_path) then
    vim.cmd[[tabnew]]
    fn.set_tab_cwd(workspace_path)
    fn.load_workspace()
  end
end
--}}}
