-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function get_tab_cwd(tabnr)
  return tabnr and vim.fn.getcwd(-1, tabnr) or vim.fn.getcwd(-1)
end

local function set_tab_cwd(path)
  if vim.fn.getcwd(-1) ~= path then
    vim.cmd("silent tcd "..vim.fn.fnameescape(vim.fn.fnamemodify(path, ":.")))
  end
end

local function resolve_path(tabnrOrPath)
  return type(tabnrOrPath) == "string"
    and vim.fn.expand(tabnrOrPath)
    or get_tab_cwd(tabnrOrPath)
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

local function get_git_info(tabnrOrPath)
  local key = resolve_path(tabnrOrPath)
  local info = dir_git_info[key]
  while not info do
    key = vim.fn.fnamemodify(key, ":h")
    if key == "/" or key == "." then
      break
    end
    info = dir_git_info[key]
  end
  return info
end

local function set_git_info(tabnrOrPath, info)
  local key = resolve_path(tabnrOrPath)
  local val = dir_git_info[key]
  dir_git_info[key] = info and vim.tbl_extend("force", val or {}, info)
end

local function run_git_command(tabnrOrPath, command)
  local git = string.format("git -C '%s' ", resolve_path(tabnrOrPath))
  return vim.trim(vim.fn.system(git..command))
end

function fn.is_git_dir(tabnrOrPath)
  local info = get_git_info(tabnrOrPath)
  return info and (info.is_git_dir or false) or false
end

function fn.get_git_branch(tabnrOrPath)
  local info = get_git_info(tabnrOrPath)
  return info and info.branch
end

function fn.refresh_git_diff_info(tabnrOrPath)
  if fn.is_git_dir(tabnrOrPath) then
    local branch = fn.get_git_branch(tabnrOrPath)
    local command = string.format("rev-list --left-right --count %s@{upstream}...%s", branch, branch)
    local results = vim.split(run_git_command(tabnrOrPath, command), "\t", { trimempty = true })
    local has_remote = vim.v.shell_error == 0
    set_git_info(tabnrOrPath, { has_remote = has_remote })
    if has_remote then
      set_git_info(tabnrOrPath, {
        local_change_count = tonumber(results[2]),
        remote_change_count = tonumber(results[1]),
      })
    else
      command = string.format("rev-list --count %s", branch)
      local output = run_git_command(tabnrOrPath, command)
      set_git_info(tabnrOrPath, { local_change_count = tonumber(output) })
    end
  end
end

function fn.refresh_git_info(tabnrOrPath)
  local branch = run_git_command(tabnrOrPath, "branch --show-current")
  local is_git_dir = vim.v.shell_error == 0
  set_git_info(tabnrOrPath, { is_git_dir = is_git_dir })
  if is_git_dir then
    set_git_info(tabnrOrPath, { branch = branch })
    local dir = run_git_command(tabnrOrPath, "rev-parse --show-toplevel")
    set_git_info(tabnrOrPath, { dir = dir })
    fn.refresh_git_diff_info(tabnrOrPath)
  else
    set_git_info(tabnrOrPath, nil)
  end
end

function fn.get_git_dir(tabnrOrPath)
  local info = get_git_info(tabnrOrPath)
  return info and info.dir
end

function fn.has_git_remote(tabnrOrPath)
  local info = get_git_info(tabnrOrPath)
  return info and (info.has_remote or false) or false
end

function fn.git_local_change_count(tabnrOrPath)
  local info = get_git_info(tabnrOrPath)
  return info and (info.local_change_count or 0) or 0
end

function fn.git_remote_change_count(tabnrOrPath)
  local info = get_git_info(tabnrOrPath)
  return info and (info.remote_change_count or 0) or 0
end

function fn.get_git_worktree_root(tabnrOrPath)
  local folder = resolve_path(tabnrOrPath)
  if not fn.is_git_dir(tabnrOrPath) then
    return folder
  end
  local branch = fn.get_git_branch(tabnrOrPath)
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
  vim.cmd.edit(vim.fn.fnameescape(path))
end

function fn.move_file()
  local rel_file = vim.fn.expand("%:~:.")
  local path = vim.fn.input("  Move to: ", rel_file, "file")
  if #path == 0 or path == rel_file then
    return
  end
  create_parent_dirs(path)
  vim.cmd.saveas(vim.fn.fnameescape(path))
  vim.fn.delete(vim.fn.expand("#"))
  vim.cmd.bwipeout("#")
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
  vim.cmd.saveas(vim.fn.fnameescape(path))
end

function fn.open_file_list()
  local terminal = require'toggleterm.terminal'.get(1, true)
  local did_open_new = false
  if terminal == nil then
    terminal = require'toggleterm.terminal'.Terminal:new{
      id = 1,
      cmd = "broot --conf ~/.config/broot/nvim.toml -c :open_preview",
      direction = "float",
      float_opts = {
        border = "single",
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
      },
    }
    did_open_new = true
  end
  terminal:open()
  if did_open_new then
    vim.api.nvim_buf_set_keymap(0, "t", [[<M-;>]], [[<Nop>]],
      { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "t", [[<M-j>]], [[<Down>]],
      { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "t", [[<M-k>]], [[<Up>]],
      { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "t", [[<M-l>]], [[<Nop>]],
      { noremap = true, silent = true })
    vim.api.nvim_create_autocmd("TermLeave", {
      group = vim.api.nvim_create_augroup("file_list_dismisser", { clear = true }),
      buffer = 0,
      callback = function()
        terminal:close()
      end,
    })
  end
end

function fn.open_file_folder()
  local shellslash
  if vim.fn.has("win32") == 1 then
    shellslash = vim.o.shellslash
    vim.o.shellslash = false
  end
  local folder = vim.fn.expand"%:p:h"
  if vim.fn.has("win32") == 1 then
    vim.o.shellslash = shellslash
  end
  local job = require'plenary.job':new {
    args = { folder },
    command = vim.fn.has("win32") == 1 and "explorer" or "open",
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
        vim.cmd.AsyncTask(job.exec)
      elseif job.kind == "command" then
        vim.cmd.AsyncRun(job.exec)
      end
    end
  end,
})

function fn.run_task(task)
  if not fn.get_is_job_in_progress() then
    vim.cmd.AsyncTask(task)
  else
    job_info.queue[task] = "task"
  end
end

function fn.run_command(command)
  if not fn.get_is_job_in_progress() then
    vim.cmd.AsyncRun(command)
  else
    job_info.queue[command] = "command"
  end
end

function fn.project_check()
  local filename = vim.api.nvim_buf_get_name(0)
  fn.run_task(("project-check +file=\"%s\""):format(filename))
end
--}}}
--{{{ Debugging
local debug_info = {
  keymaps = {},
  state = 0,
  toolbar_states = {
    [[  [~]  [<Ins>]  [<F10>] 󰗼 [<F12>] ]],
    [[  [~]  [<Ins>]  [<F10>]  [<F6>]  [<F7>]  [<F8>]  [<F9>]  [<F11>]  [<F12>] ]],
    [[  [~]  [<Ins>]  [<F10>]  [<F11>]  [<F12>] ]],
  },
  toolbar = {
    {
      [[<Ins>]],
      action = [[toggle_breakpoint]],
      icon = {
        '',
        color = "Function",
      },
      states = { 1, 2, 3 },
    },
    {
      [[<F10>]],
      action = function()
        if vim.bo.filetype == "dart" then
          vim.notify("Detecting devices...", "INFO", { title = "FlutterTools" })
          vim.cmd[[FlutterDevices]]
        else
          require'dap'.continue()
        end
      end,
      icon = {
        '',
        color = "Operator",
      },
      states = { 1 },
    },
    {
      [[<F10>]],
      action = [[continue]],
      icon = {
        '',
        color = "Function",
      },
      states = { 2 },
    },
    {
      [[<F10>]],
      action = [[pause]],
      icon = {
        '',
        color = "Function",
      },
      states = { 3 },
    },
    {
      [[<F6>]],
      action = [[step_over]],
      icon = {
        '',
        color = "Function",
      },
      states = { 2 },
    },
    {
      [[<F7>]],
      action = [[step_into]],
      icon = {
        '',
        color = "Function",
      },
      states = { 2 },
    },
    {
      [[<F8>]],
      action = [[step_out]],
      icon = {
        '',
        color = "Function",
      },
      states = { 2 },
    },
    {
      [[<F9>]],
      action = [[run_to_cursor]],
      icon = {
        '',
        color = "Operator",
      },
      states = { 2 },
    },
    {
      [[<F11>]],
      action = function()
        if vim.bo.filetype == "dart" then
          vim.cmd[[FlutterRestart]]
        else
          require'dap'.restart()
        end
      end,
      icon = {
        '',
        color = "Function",
      },
      states = { 2, 3 },
    },
    {
      [[<F12>]],
      action = nil,
      icon = {
        '󰗼',
        color = "Special",
      },
      states = { 1 },
    },
    {
      [[<F12>]],
      action = function()
        if vim.bo.filetype == "dart" then
          vim.cmd[[FlutterQuit]]
        else
          require'dap'.terminate()
        end
      end,
      icon = {
        '',
        color = "Error",
      },
      states = { 2, 3 },
    },
  },
}

function fn.get_is_debugging()
  return debug_info.state ~= 0
end

local function get_debug_button_callback(button)
  if type(button.action) == "string" then
    return require'dap'[button.action]
  end
  return button.action
end

local function set_debugging_keymap(lhs, callback)
  local keymap = debug_info.keymaps[lhs]
  if keymap == nil then
    keymap = vim.fn.maparg(lhs, "n", 0, 1)
    keymap.lhs = lhs
    debug_info.keymaps[lhs] = keymap
  end

  keymap.is_overridden = true

  vim.api.nvim_set_keymap("n", lhs, [[]], {
    callback = function()
      callback()
    end,
    noremap = true,
  })
end

local function unset_debugging_keymap(lhs)
  local keymap = debug_info.keymaps[lhs]
  if keymap and keymap.is_overridden then
    if keymap.rhs or keymap.callback then
      vim.api.nvim_set_keymap("n", keymap.lhs, keymap.rhs or [[]], {
        callback = keymap.callback,
        expr = keymap.expr,
        noremap = keymap.noremap,
        nowait = keymap.nowait,
        silent = keymap.silent,
        script = keymap.script,
      })
    else
      vim.api.nvim_del_keymap("n", keymap.lhs)
    end
    keymap.is_overridden = false
  end
end

local function unset_debugging_keymaps()
  for lhs, _ in pairs(debug_info.keymaps) do
    unset_debugging_keymap(lhs)
  end
end

function fn.stop_debugging()
  if debug_info.state ~= 0 then
    unset_debugging_keymaps()

    debug_info.state = 0
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
end

local function update_debugging_state(state)
  if state > 0 then
    debug_info.state = state

    unset_debugging_keymaps()

    for _, button in ipairs(debug_info.toolbar) do
      if vim.tbl_contains(button.states, state) then
        local callback = get_debug_button_callback(button)
          or fn.stop_debugging
        set_debugging_keymap(button[1], callback)
      end
    end
  end

  require'lualine'.refresh{ place = { "tabline" } }
end

function fn.resume_debugging()
  if debug_info.state == 0 then
    require'dapui'.open()

    update_debugging_state(1)
  end

  require'dap'.listeners.after.event_continued.my_debug_event = function()
    update_debugging_state(3)
  end
  require'dap'.listeners.after.continue.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.attach.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.launch.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.event_stopped.my_debug_event = function()
    update_debugging_state(2)
  end
  require'dap'.listeners.after.event_exited.my_debug_event =
    require'dap'.listeners.after.event_stopped.my_debug_event
  require'dap'.listeners.after.event_terminated.my_debug_event = function()
    update_debugging_state(1)
  end
  require'dap'.listeners.after.disconnect.my_debug_event =
    require'dap'.listeners.after.event_terminated.my_debug_event
  require'dap'.listeners.after.terminate.my_debug_event =
    require'dap'.listeners.after.event_terminated.my_debug_event
end

function fn.get_debug_toolbar()
  local components = {}
  for _, button in ipairs(debug_info.toolbar) do
    local callback = get_debug_button_callback(button)
      or fn.stop_debugging
    local component = {
      function()
        return ("[%s]"):format(button[1])
      end,
      color = "Comment",
      cond = function()
        return vim.tbl_contains(button.states, debug_info.state)
      end,
      icon = button.icon,
      on_click = function()
        callback()
      end,
    }
    table.insert(components, component)
  end
  return components
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
    local opts = {
      filter_rules = {
        bo = {
          filetype = {
            "lazy",
            "qf",
          },
          buftype = {
            "terminal",
          },
        },
      },
    }
    target_winid = require'window-picker'.pick_window(opts)
    if target_winid ~= -1 then
      vim.api.nvim_set_current_win(target_winid)
    end
    vim.cmd[mode](path)
  else
    vim.api.nvim_set_current_win(target_winid)
  end
end

function fn.choose_window()
  local picked = require'window-picker'.pick_window {
    autoselect_one = false,
  }
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

function fn.open_tab(filename)
  vim.cmd.tabe(vim.fn.fnameescape(filename))
end

function fn.close_buffer()
  if #vim.api.nvim_tabpage_list_wins(0) > 0 then
    vim.cmd[[close]]
  else
    require'mini.bufremove'.unshow()
  end
end
--}}}
--{{{ Quickfix
local function open_quickfix()
  vim.cmd(("%dcopen"):format(math.min(#vim.fn.getqflist(), vim.o.lines / 6)))
  vim.cmd.wincmd[[J]]
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

function fn.find_buf_in_loclist(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    for index, entry in ipairs(vim.fn.getloclist(win)) do
      if entry.bufnr == bufnr then
        return {
          win = win,
          index = index,
        }
      end
    end
  end
end

function fn.add_buf_to_loclist(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local infos = vim.fn.getbufinfo(bufnr)
  if #infos > 0 and fn.is_file_buffer(bufnr) then
    local info = infos[1]
    if info.listed == 1 then
      for _, win in ipairs(info.windows) do
        local list = vim.fn.getloclist(win)
        for i, entry in ipairs(list) do
          if entry.bufnr == bufnr then
            table.remove(list, i)
            break
          end
        end
        table.insert(list, 1, {
          bufnr = bufnr,
          lnum = info.lnum,
        })
        vim.fn.setloclist(win, list, "r")
      end
    end
  end
end

function fn.del_buf_from_loclist(bufnr)
  local loc = fn.find_buf_in_loclist(bufnr)
  if loc ~= nil then
    local list = vim.fn.getloclist(loc.win)
    table.remove(list, loc.index)
    vim.fn.setloclist(loc.win, list, "r")
  end
end
--}}}
--{{{ Terminal
local function get_terminal()
  return require'toggleterm.terminal'.Terminal:new{
    id = 0,
    cmd = "zsh --login",
    direction = "tab",
    env = {
      STARSHIP_CONFIG = "~/.dotfiles/starship.minimal.toml",
    },
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
  set_tab_cwd(cwd)
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
  return #vim.bo[buf or 0].buftype == 0 and not fn.is_empty_buffer(buf)
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

function fn.shell_str(string)
  return vim.trim(vim.fn.system(("echo \"%s\""):format(string)))
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

--}}}
--{{{ Workspace
local function get_workspace_file_path(tabnr)
  return fn.get_workspace_dir(tabnr).."/"..vim.g.workspace_file_name
end

local function get_workspace_file(tabnr)
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

function fn.get_workspace_dir(tabnrOrPath)
  if fn.is_git_dir(tabnrOrPath) then
    return fn.get_git_dir(tabnrOrPath)
  end
  return resolve_path(tabnrOrPath)
end

function fn.is_workspace_frozen(tabnr)
  return vim.fn.gettabvar(
    tabnr or vim.fn.tabpagenr(),
    "is_workspace_frozen",
    false)
end

function fn.freeze_workspace(tabnr, value)
  vim.fn.settabvar(
    tabnr or vim.fn.tabpagenr(),
    "is_workspace_frozen",
    value == nil or value)
end

function fn.show_workspace(tabnr, value)
  if not fn.is_workspace_frozen(tabnr) then
    local root = fn.get_workspace_dir(tabnr)
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
      set_tab_cwd(work_dir)
    end
  end
end

function fn.open_workspace(path)
  local workspace_path = fn.get_git_worktree_root(path)
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
    set_tab_cwd(".")
    fn.load_workspace()
  end
end
--}}}
