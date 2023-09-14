-- vim: foldmethod=marker foldlevel=0 foldenable

--{{{ Helpers
local function resolve_path(tabpageOrPath)
  return type(tabpageOrPath) == "string"
    and tostring(vim.fn.expand(tabpageOrPath))
    or fn.get_tab_cwd(tabpageOrPath)
end
--}}}
--{{{ Git
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
    local is_ok, gitsigns = pcall(require, 'gitsigns.actions')
    if is_ok then
      pcall(gitsigns.refresh)
    end
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

function fn.open_in_github(path)
  local remote = run_git_command(path, "remote get-url origin")
  local repo_path = remote:sub(1, 4) == "http"
    and remote:match[[com/(.*)%.]]
    or remote:match[[com:(.*)%.]]
  local file_path = path or vim.api.nvim_buf_get_name(0)
  local info = get_git_info(file_path)
  file_path = vim.fn.substitute(file_path, info.dir.."/", "", "")
  local url = ("https://github.com/%s/blob/%s/%s")
    :format(repo_path, info.branch, file_path)
  if not path and vim.fn.mode() == "V" then
    url = url.."#L"..vim.api.nvim_win_get_cursor(0)[1]
  end
  local job = require'plenary.job':new {
    args = { url },
    command = vim.fn.has("win32") == 1 and "explorer" or "open",
    detached = true,
  }
  job:start()
end
--}}}
--{{{ Files
local function create_parent_dirs(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end

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
  vim.fn.delete(tostring(vim.fn.expand('%:p')))
  require'mini.bufremove'.wipeout()
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
      vim.cmd.edit(vim.fn.fnameescape(path))
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
      vim.cmd.saveas(vim.fn.fnameescape(path))
      vim.fn.delete(tostring(vim.fn.expand("#")))
      vim.cmd.bwipeout("#")
    end)
end

function fn.save_file()
  if not fn.is_empty_buffer() then
    vim.cmd[[silent update]]
    return
  end
  local rel_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")
  vim.ui.input({
      completion = "dir",
      default = rel_dir.."/",
      prompt = " 󰈔 Save to: ",
      dressing = {
        relative = "win",
      },
    },
    function(path)
      if path == nil or #path == 0 or path == rel_dir or path.."/" == rel_dir then
        return
      end
      create_parent_dirs(path)
      vim.cmd.saveas(vim.fn.fnameescape(path))
    end)
end

function fn.open_explorer()
  local terminal = require'toggleterm.terminal'.get(1, true)
  local did_open_new = false
  if terminal == nil then
    local cwd = vim.fn.getcwd()
    local conf = vim.fn.filereadable("./.nvim/explorer.toml") == 1
      and "./.nvim/explorer.toml"
      or ("~/.config/broot/%s.toml"):format(vim.g.project_type or "base")
    terminal = require'toggleterm.terminal'.Terminal:new{
      id = 1,
      cmd = ("broot --conf %s -c :open_preview '%s'"):format(conf, cwd),
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
--{{{ Tasks
local function vim_task_def(name, args, cwd, deps, func)
  if not _G.task_cb_id then
    _G.task_cb_id = 0
    _G.task_cb_reg = {}
    _G.task_cb_runner = function(id)
      local cb = _G.task_cb_reg[id]
      local old_cwd = vim.fn.getcwd()
      if cb.cwd then
        vim.api.nvim_set_current_dir(cb.cwd)
      end
      local is_ok, out = pcall(cb.func, cb.args)
      if cb.cwd then
        vim.api.nvim_set_current_dir(old_cwd)
      end
      _G.task_cb_reg[id] = nil
      if not is_ok then
        error(out)
      end
      return out or ''
    end
  end
  _G.task_cb_id = _G.task_cb_id + 1
  _G.task_cb_reg[_G.task_cb_id] = {
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
      'v:lua.task_cb_runner('.._G.task_cb_id..')',
    },
    cmd = { vim.v.progpath },
    components = deps,
    name = name,
  }
end

function fn.create_task(name, config)
  local is_ok, overseer = pcall(require, 'overseer')
  if is_ok then
    overseer.register_template {
      name = name,
      builder = function(params)
        local args = vim.list_extend(
          vim.deepcopy(config.args or {}),
          vim.deepcopy(params.args or {}))
        local deps = {
          config.notify == false
            and { 'on_complete_notify', statuses = {} }
            or 'on_complete_notify',
          { 'run_after', task_names = config.deps or {} },
          'on_output_quickfix',
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
          return vim_task_def(
            name,
            args,
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
      params = {
        args = {
          delimiter = ',',
          desc = "Task arguments",
          optional = true,
          subtype = { type = 'string' },
          type = 'list',
        },
      },
      priority = config.priority,
    }
  end
end

function fn.has_task(name)
  local is_ok, overseer_template = pcall(require, 'overseer.template')
  if not is_ok then
    return false
  end
  local task_def
  overseer_template.get_by_name(
    name,
    { dir = fn.get_workspace_dir() },
    function(def)
      task_def = def
    end)
  return task_def ~= nil
end

function fn.run_task(name, args)
  local is_ok, overseer = pcall(require, 'overseer')
  if is_ok then
    overseer.run_template {
      name = name,
      params = { args = args },
    }
  end
end
--}}}
--{{{ Debugging
local debug_info = {
  keymaps = {},
  state = 0,
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
      action = [[continue]],
      icon = {
        '',
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
      action = [[restart]],
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
      action = [[terminate]],
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

function fn.get_debug_callback(action)
  return function()
    local action_name = action:gsub('_', ' ')
    local task_name_1 = ('Debug %s'):format(action_name)
    local task_name_2 = ('Debug %s %s'):format(action_name, debug_info.state)
    if fn.has_task(task_name_1) then
      fn.run_task(task_name_1)
    elseif fn.has_task(task_name_2) then
      fn.run_task(task_name_2)
    else
      require'dap'[action]()
    end
  end
end

local function get_debug_button_callback(button)
  if type(button.action) == 'string' then
    return fn.get_debug_callback(button.action)
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

  vim.api.nvim_set_keymap("n", lhs, [[]], {
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

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_win_set_option(win, "numberwidth",
      vim.api.nvim_win_get_option(win, "numberwidth"))
  end
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

    set_debugging_keymap([[<leader>b]], function()
      require'telescope'.extensions.dap.list_breakpoints{}
    end, "List breakpoints")
  end
end

function fn.resume_debugging()
  if debug_info.state == 0 then
    require'dapui'.open(1)

    update_debugging_state(1)
  end

  require'dap'.listeners.after.event_continued.my_debug_event = function()
    require'dapui'.close(2)

    update_debugging_state(3)
  end
  require'dap'.listeners.after.continue.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.attach.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.launch.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.event_stopped.my_debug_event = function()
    require'dapui'.open(2)

    update_debugging_state(2)
  end
  require'dap'.listeners.after.event_exited.my_debug_event =
    require'dap'.listeners.after.event_stopped.my_debug_event
  require'dap'.listeners.after.event_terminated.my_debug_event = function()
    require'dapui'.close(2)

    update_debugging_state(1)
  end
  require'dap'.listeners.after.disconnect.my_debug_event =
    require'dap'.listeners.after.event_terminated.my_debug_event
  require'dap'.listeners.after.terminate.my_debug_event =
    require'dap'.listeners.after.event_terminated.my_debug_event
end

function fn.get_debug_toolbar()
  local components = {}
  for i, button in ipairs(debug_info.toolbar) do
    local btn_cb = get_debug_button_callback(button)
      or fn.stop_debugging
    table.insert(components, {
      action = button.action or ('action_'..i),
      highlight = button.icon.color,
      icon = button.icon[1],
      keymap = button[1],
      click_cb = function()
        btn_cb()
      end,
      cond_cb = function()
        return vim.tbl_contains(button.states, debug_info.state)
      end,
    })
  end
  return components
end
--}}}
--{{{ LSP
local lsp_info = {
  notifications = {},
  spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
}

local function get_lsp_notif_data(client_id, _)
  local key = vim.lsp.get_client_by_id(client_id).name

  if not lsp_info.notifications[key] then
    lsp_info.notifications[key] = {}
  end

  return lsp_info.notifications[key]
end

local function update_spinner(client_id, token)
 local notif_data = get_lsp_notif_data(client_id, token)

 if notif_data.spinner and notif_data.notification then
   local new_spinner = (notif_data.spinner + 1) % #lsp_info.spinner_frames
   notif_data.spinner = new_spinner

   notif_data.notification = vim.notify(nil, nil, {
     hide_from_history = true,
     icon = lsp_info.spinner_frames[new_spinner],
     replace = notif_data.notification,
   })

   vim.defer_fn(function()
     update_spinner(client_id, token)
   end, 100)
 end
end

local function format_title(title, client)
  return client.name..(#title > 0 and ": "..title or "")
end

local function format_message(message, part, total)
  if part and total then
    return ((part.." \\ "..total.."\t") or "")..(message or "")
  elseif part and not total then
    return (part.."%\t" or "")..(message or "")
  elseif message then
    return message
  else
    return "0%\t"
  end
end

function fn.show_lsp_progress(client_id, token, info)
  if not info.kind then
    return
  end

  local notif_data = get_lsp_notif_data(client_id, token)

  if info.kind == "begin" then
    local message
    if not notif_data.notification or not notif_data.index then
      message = format_message(info.message, info.percentage)

      notif_data.index = 1
      notif_data.count = 1
    else
      notif_data.index = notif_data.index + 1
      notif_data.count = notif_data.count + 1

      message = format_message(info.message, notif_data.index, notif_data.count)
    end

    notif_data.spinner = 1
    notif_data.notification = vim.notify(message, vim.log.levels.INFO, {
      hide_from_history = notif_data.index > 1,
      icon = lsp_info.spinner_frames[1],
      replace = notif_data.notification,
      title = format_title(info.title, vim.lsp.get_client_by_id(client_id)),
    })

    update_spinner(client_id, token)
  elseif info.kind == "report" and notif_data and notif_data.index ~= nil then
    local message
    if notif_data.index <= 1 then
      message = format_message(info.message, info.percentage)
    else
      message = format_message(info.message, notif_data.index, notif_data.count)
    end

    notif_data.notification = vim.notify(
      message,
      vim.log.levels.INFO,
      {
        hide_from_history = true,
        replace = notif_data.notification,
      }
    )
  elseif info.kind == "end" and notif_data and notif_data.index ~= nil then
    notif_data.index = notif_data.index - 1

    local icon, message
    if notif_data.index < 1 then
      notif_data.index = 0
      notif_data.count = 0
      notif_data.spinner = nil

      icon = ''
      message = info.message and format_message(info.message) or "Done"
    else
      message = format_message(info.message, notif_data.index, notif_data.count)
    end

    notif_data.notification = vim.notify(
      message,
      vim.log.levels.INFO,
      {
        hide_from_history = notif_data.index > 0,
        icon = icon,
        on_close = function()
          notif_data.notification = nil
        end,
        replace = notif_data.notification,
      }
    )
  end
end

--}}}
--{{{ Navigation
local nav_info = {}

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

function fn.get_prior_tabpage()
  local tabnr = vim.fn.tabpagenr[[#]]
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.api.nvim_tabpage_get_number(tabpage) == tabnr then
      return tabpage
    end
  end
end

function fn.open_tab(filename)
  vim.cmd.tabe(vim.fn.fnameescape(filename))
  fn.freeze_workspace()
end

function fn.close_buffer()
  if #vim.api.nvim_tabpage_list_wins(0) > 0 then
    vim.cmd[[close]]
  else
    require'mini.bufremove'.unshow()
  end
end

function fn.restore_tabpage()
  if nav_info.last_tabpage and
      vim.api.nvim_tabpage_is_valid(nav_info.last_tabpage) then
    pcall(vim.api.nvim_set_current_tabpage, nav_info.last_tabpage)
    nav_info.last_tabpage = nil
  end
end

function fn.save_tabpage()
  local cur_tabpage = vim.api.nvim_get_current_tabpage()
  fn.vim_defer(function()
    nav_info.last_tabpage = cur_tabpage
  end)()
end

function fn.show_buffer_jump_picker(dir)
  require'portal.builtin'.jumplist.tunnel({
    direction = dir,
    filter = function(j)
      return j.buffer == vim.api.nvim_get_current_buf()
    end,
  })
end

function fn.goto_bookmark(tag)
  if not require'grapple'.exists{ key = tag } then
    require'grapple'.tag{ key = tag }
    vim.o.showtabline = 2
  end
  require'grapple'.select{ key = tag }
end

function fn.del_bookmark(tag)
  require'grapple'.untag{ key = tag }
  if #require'grapple'.tags() == 0 then
    vim.o.showtabline = 0
  end
end
--}}}
--{{{ Quickfix
local function foreach_buf_in_loclists(bufnr, callback)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    for i, entry in ipairs(vim.fn.getloclist(win)) do
      if entry.qfbufnr == bufnr then
        callback(i, win)
        break
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
        local list = vim.tbl_filter(
          function(e)
            return e.bufnr ~= bufnr
          end,
          vim.fn.getloclist(win)
        )
        local cur = vim.api.nvim_win_get_cursor(win)
        table.insert(list, 1, {
          bufnr = bufnr,
          col = cur[2],
          lnum = cur[1],
        })
        vim.fn.setloclist(win, list, "r")
      end
    end
  end
end

function fn.del_buf_from_loclist(bufnr)
  foreach_buf_in_loclists(bufnr, function(i, win)
    local list = vim.fn.getloclist(win)
    table.remove(list, i)
    vim.fn.setloclist(win, list, "r")
  end)
end
--}}}
--{{{ Terminal
local term_info = {}

local function get_terminal()
  return require'toggleterm.terminal'.Terminal:new {
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
      vim.api.nvim_set_current_tabpage(fn.get_prior_tabpage())
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
  fn.set_tab_cwd(nil, cwd)
end

function fn.send_terminal(command, is_hist, should_focus)
  get_terminal():send((is_hist and '' or ' ')..command,
    should_focus ~= nil and not should_focus)
end

function fn.set_shell_active(is_active, cmd, exit_code)
  term_info.is_shell_active = is_active
  if not is_active and not get_terminal():is_focused() and cmd:sub(1, 1) ~= " " then
    vim.notify(
      "exited with code "..exit_code,
      vim.log.levels.INFO,
      { title = cmd }
    )
  end
end

function fn.get_shell_active()
  return term_info.is_shell_active
end

function fn.sync_terminal()
  local terminal = get_terminal()
  if terminal.window ~= nil then
    local tabpage = vim.api.nvim_win_get_tabpage(terminal.window)
    if vim.api.nvim_get_current_tabpage() == tabpage then
      local cwd = fn.get_tab_cwd(fn.get_prior_tabpage())
      if terminal.dir ~= cwd then
        fn.send_terminal("cd "..cwd)
      end
    end
  end
end

function fn.is_terminal_buf(buf)
  for _, term in ipairs(require'toggleterm.terminal'.get_all(true)) do
    if term.bufnr == buf then
      return true
    end
  end
  return false
end
--}}}
--{{{ Utilities
function fn.get_my_config_json(key)
  return vim.fn.json_encode(my_config[key])
end

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
  vim.cmd("tcd "..vim.fn.fnameescape(cwd))
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
  if #name > 0 and vim.fn.fnamemodify(name, ":t") ~= "new" then
    return false
  end
  local lines = vim.api.nvim_buf_get_lines(buf or 0, 0, -1, false)
  return #lines == 0 or (#lines == 1 and #lines[1] == 0)
end

function fn.is_file_buffer(buf)
  if #vim.bo[buf or 0].buftype > 0 then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf or 0)
  return #name > 0 and vim.fn.fnamemodify(name, ":t") ~= "new"
end

function fn.get_wins_for_buf_type(buf_type)
  return vim.fn.filter(
    vim.fn.range(1, vim.fn.winnr("$")),
    ("getwinvar(v:val, '&bt') == '%s'"):format(buf_type))
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

function fn.apply_unfocused_highlight()
  local focused_hl_ns = vim.api.nvim_create_namespace("focused_highlights")
  local normal_hl = vim.api.nvim_get_hl(focused_hl_ns, { name = "Normal" })
  if normal_hl.bg == nil then
    normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    local normalnc_hl = vim.api.nvim_get_hl(0, { name = "NormalNC" })
    vim.api.nvim_set_hl(focused_hl_ns, "Normal", normal_hl)
    vim.api.nvim_set_hl(focused_hl_ns, "NormalNC", normalnc_hl)
  end
  local unfocused_bg = require'catppuccin.palettes'.get_palette("macchiato").base
  vim.api.nvim_set_hl(0, "Normal", { bg = unfocused_bg })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = unfocused_bg })
end

function fn.apply_focused_highlight()
  local focused_hl_ns = vim.api.nvim_create_namespace("focused_highlights")
  local normal_hl = vim.api.nvim_get_hl(focused_hl_ns, { name = "Normal" })
  local normalnc_hl = vim.api.nvim_get_hl(focused_hl_ns, { name = "NormalNC" })
  if normal_hl.bg ~= nil then
    vim.api.nvim_set_hl(0, "Normal", normal_hl)
    vim.api.nvim_set_hl(0, "NormalNC", normalnc_hl)
  end
end

function fn.foldfunc(close, start_open, open, sep, end_sep)
  local C = require'ffi'.C
  return function(args)
    local width = C.compute_foldcolumn(args.wp, 0)
    if C.compute_foldcolumn(args.wp, 0) == 0 then
      return ""
    end

    local foldinfo = C.fold_info(args.wp, args.lnum)

    local string = args.cul and args.relnum == 0
      and "%#CursorLineFold#"
      or "%#FoldColumn#"

    local level = foldinfo.level
    if level == 0 then
      return string..(" "):rep(width).."%*"
    end

    local closed = foldinfo.lines > 0

    local first_level = level - width - (closed and 1 or 0) + 1
    if first_level < 1 then
      first_level = 1
    end

    local range = level < width and level or width
    for col = 1, range do
      if closed and (col == level or col == width) then
        string = string..close
      elseif foldinfo.start == args.lnum
        and first_level + col > foldinfo.llevel then
        local prev_foldinfo = C.fold_info(args.wp, args.lnum - 1)
        if prev_foldinfo.level == 0 then
          string = string..start_open
        else
          string = string..open
        end
      else
        local next_foldinfo = C.fold_info(args.wp, args.lnum + 1)
        if next_foldinfo.level ~= 0 then
          string = string..sep
        else
          string = string..end_sep
        end
      end
    end
    if range < width then
      string = string..(" "):rep(width - range)
    end
    return string.."%*"
  end
end

function fn.is_floating(win)
  return vim.api.nvim_win_get_config(win or 0).relative ~= [[]]
end
--}}}
--{{{ Workspace
local function get_workspace_file_path(tabpage)
  return fn.get_workspace_dir(tabpage).."/"..vim.g.workspace_file_name
end

local function load_workspace(tabpage)
  if not fn.is_workspace_frozen(tabpage) then
    local workspace_file = io.open(get_workspace_file_path(tabpage), "r")
    if workspace_file ~= nil then
      fn.freeze_workspace(tabpage, false)
      local workspace_path = fn.get_workspace_dir(tabpage)
      local workspace_conf = workspace_file:read("*a")
      vim.api.nvim_exec2(workspace_conf, { output = false })
      io.close(workspace_file)
      fn.set_tab_cwd(tabpage, workspace_path)
    end
  end
end

function fn.get_workspace_dir(tabpageOrPath)
  if fn.is_git_dir(tabpageOrPath) then
    return fn.get_git_dir(tabpageOrPath)
  end
  return resolve_path(tabpageOrPath)
end

function fn.has_workspace_file(tabpage)
  return vim.fn.filereadable(get_workspace_file_path(tabpage))
end

function fn.is_workspace_frozen(tabpage)
  local has_var, is_workspace_frozen = pcall(
    vim.api.nvim_tabpage_get_var,
    tabpage or vim.api.nvim_get_current_tabpage(),
    "is_workspace_frozen"
  )
  return has_var and is_workspace_frozen
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
  if (vim.env.PARENT_NVIM == nil and
      not fn.is_workspace_frozen(tabpage))
      or (force or false) then
    fn.freeze_workspace(tabpage, false)
    local save_path = get_workspace_file_path(tabpage)
    create_parent_dirs(save_path)
    vim.cmd("silent mksession! "..vim.fn.fnameescape(save_path))
  end
end

function fn.open_workspace(path)
  local workspace_path = fn.get_git_dir(path)
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local cwd = fn.get_tab_cwd(tabpage)
    if cwd == workspace_path then
      if not fn.is_workspace_frozen(tabpage) then
        vim.api.nvim_set_current_tabpage(tabpage)
        return
      end
    end
  end
  if vim.fn.isdirectory(workspace_path) then
    vim.cmd[[tabnew]]
    fn.set_tab_cwd(nil, workspace_path)
    load_workspace(nil)
  end
end
--}}}
