-- vim: fcl=all fdm=marker fdl=0 fen

local fn = {}

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
    fn.vim_defer(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if fn.is_file_buffer(vim.api.nvim_win_get_buf(win)) then
          vim.fn.win_execute(win, [[edit]])
        end
      end
    end)()
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
      command = vim.fn.expand[[~/.dotfiles/deps/gh/.local/bin/gh]],
      detached = true,
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
              command = vim.fn.expand[[~/.dotfiles/deps/gh/.local/bin/gh]],
              detached = true,
            }:start()
          end)()
        end
      end,
    }:start()
  else
    fn.open_file_folder(path)
  end
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
  local rel_file = vim.fn.expand('%:~:.')

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
      vim.cmd.saveas(vim.fn.fnameescape(path))
    end)
end

function fn.open_folder(path)
  local shellslash
  if vim.fn.has('win32') == 1 then
    shellslash = vim.o.shellslash
    vim.o.shellslash = false
    path = path and path:gsub('/', '\\')
  end
  local folder = path or vim.fn.getcwd()
  if vim.fn.has('win32') == 1 then
    vim.o.shellslash = shellslash
  end
  require'plenary.job':new{
    args = { folder },
    command = vim.fn.has('win32') == 1 and 'explorer' or 'open',
    detached = true,
  }:start()
end

function fn.open_file_folder(path)
  local folder = path
    and vim.fn.fnamemodify(path, ':p:h')
    or vim.fn.expand'%:p:h'
  fn.open_folder(folder)
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
          {
            'on_output_quickfix',
            errorformat = config.errorformat,
            set_diagnostics = true,
          },
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
    local params = { args = {} }
    if args then
      for k, v in pairs(args) do
        if type(k) == 'number' then
          params.args[k] = v
        else
          params[k] = v
        end
      end
    end
    overseer.run_template {
      name = name,
      params = params,
    }
  end
end

function fn.running_task_count()
  local is_ok, overseer_task_list = pcall(require, 'overseer.task_list')
  if is_ok then
    return #overseer_task_list.list_tasks {
      status = require'overseer'.STATUS.RUNNING,
    }
  end
  return 0
end

function fn.exec_task(cmd, args, name)
  local is_ok, overseer = pcall(require, 'overseer')
  if is_ok then
    overseer.new_task{
      args = args,
      cmd = cmd,
      components = {
        'on_output_quickfix',
        'default',
      },
      name = name,
    }:start()
  end
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
    update_debugging_state(1)
  end

  require'dap'.listeners.after.event_continued.my_debug_event = function()
    local splitkeep = vim.o.splitkeep
    vim.o.splitkeep = 'screen'
    require'dapui'.close(2)
    vim.o.splitkeep = splitkeep
    local equalalways = vim.o.equalalways
    vim.o.equalalways = false
    require'dapui'.open(1)
    vim.o.equalalways = equalalways

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
  require'dap'.listeners.after.launch.my_debug_event =
    require'dap'.listeners.after.event_continued.my_debug_event
  require'dap'.listeners.after.event_stopped.my_debug_event = function()
    local splitkeep = vim.o.splitkeep
    vim.o.splitkeep = 'screen'
    require'dapui'.open(2)
    vim.o.splitkeep = splitkeep

    update_debugging_state(2)
  end
  require'dap'.listeners.after.event_terminated.my_debug_event = function()
    local splitkeep = vim.o.splitkeep
    vim.o.splitkeep = 'screen'
    require'dapui'.close(2)
    vim.o.splitkeep = splitkeep

    update_debugging_state(1)
  end
  require'dap'.listeners.after.event_exited.my_debug_event =
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
  local equalalways = vim.o.equalalways
  vim.o.equalalways = false
  require'dapui'.toggle(1)
  vim.o.equalalways = equalalways
end

function fn.load_vscode_launch_json(path)
  local is_ok, result = pcall(require'dap.ext.vscode'.load_launchjs, path)
  if not is_ok then
    vim.notify(result, vim.log.levels.WARN)
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
    if target_winid and target_winid ~= -1 then
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
        local name
        if vim.fn.has('win32') == 1 then
          local shellslash = vim.o.shellslash
          vim.o.shellslash = false
          name = vim.api.nvim_buf_get_name(bufnr)
          vim.o.shellslash = shellslash
        end
        local cur = vim.api.nvim_win_get_cursor(win)
        table.insert(list, 1, {
          bufnr = bufnr,
          filename = name,
          col = cur[2],
          lnum = cur[1],
        })
        vim.fn.setloclist(win, list, 'r')
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
local term_info = {
  is_shell_active = false,
}

local function get_terminal_tabpage()
  local terminal = require'toggleterm.terminal'.get(0, true)
  return terminal and vim.api.nvim_win_get_tabpage(terminal.window)
end

local function get_terminal()
  return require'toggleterm.terminal'.Terminal:new {
    id = 0,
    cmd = 'zsh --login',
    direction = 'tab',
    env = {
      STARSHIP_CONFIG = '~/.dotfiles/starship.minimal.toml',
    },
  }
end

function fn.open_terminal()
  local tabpage = get_terminal_tabpage()
  if not tabpage then
    get_terminal():open()
  elseif vim.api.nvim_get_current_tabpage() ~= tabpage then
    vim.api.nvim_set_current_tabpage(tabpage)
  end
end

function fn.dismiss_terminal()
  local tabpage = get_terminal_tabpage()
  if vim.api.nvim_get_current_tabpage() == tabpage then
    vim.api.nvim_set_current_tabpage(fn.get_prior_tabpage())
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
  local terminal = get_terminal()
  local tabpage = vim.api.nvim_win_get_tabpage(terminal.window)
  fn.set_tab_cwd(tabpage, cwd)
  terminal.dir = fn.get_tab_cwd(tabpage)
end

function fn.send_terminal(command, is_hist, should_focus)
  get_terminal():send((is_hist and '' or ' ')..command,
    should_focus ~= nil and not should_focus)
end

function fn.set_shell_active(is_active, cmd, exit_code)
  term_info.is_shell_active = is_active
  if not is_active and not
      get_terminal():is_focused() and
      cmd:sub(1, 1) ~= ' '
  then
    vim.notify(
      "exited with code "..exit_code,
      vim.log.levels.INFO,
      { title = cmd }
    )
  end
end

function fn.is_shell_active(tabpage)
  if tabpage and tabpage ~= get_terminal_tabpage() then
    return nil
  end
  return term_info.is_shell_active
end

function fn.sync_terminal()
  local terminal = get_terminal()
  if terminal.window then
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
  buf = buf or vim.api.nvim_get_current_buf()
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
  local focused_hl_ns = vim.api.nvim_create_namespace('focused_highlights')
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
  local focused_hl_ns = vim.api.nvim_create_namespace('focused_highlights')
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

function fn.is_in_floating(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf or vim.api.nvim_get_current_buf())) do
    if fn.is_floating(win) then
      return true
    end
  end
  return false
end

function fn.get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = lines[1]:sub(s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = lines[n_lines]:sub(1, s_end[3] - s_start[3])
  else
    lines[n_lines] = lines[n_lines]:sub(1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function fn.copy_visual_selection()
  vim.fn.setreg('+', fn.get_visual_selection())
end

function fn.get_buffer_title(buf)
  return fn.is_file_buffer(buf)
    and vim.fn.pathshorten(vim.fn.expand('%:~:.'))
    or vim.o.buftype
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
  local line = 1
  local last = vim.fn.line('$')
  while line < last do
    if vim.fn.foldclosed(line) ~= -1 then
      line = vim.fn.foldclosedend(line) + 1
    elseif vim.fn.foldlevel(line) == level then
      vim.cmd(''..line..'foldclose')
      line = vim.fn.foldclosedend(line) + 1
    else
      line = line + 1
    end
  end
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

function fn.has_local_config()
  local is_ok, config_local = pcall(require, 'config-local')
  if is_ok then
    return config_local.lookup() ~= ''
  end
  return false
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
      layout_strategy = 'vertical',
      layout_config = {
        height = 0.50,
        width = 0.30,
      },
    }
  end

  return function()
    ---@diagnostic disable-next-line: redundant-parameter
    lib[obj](opts)
  end
end
--}}}
--{{{ AI
function fn.ai_gen(cmd, text)
  local filetype = vim.bo.filetype

  local lines = text
    and vim.split(text, '\n')
    or vim.api.nvim_buf_get_lines(0, 0, -1, false)

  vim.cmd[[tabe]]

  vim.bo.filetype = 'markdown'
  vim.bo.bufhidden = 'wipe'

  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

  vim.cmd('%Gp'..cmd)

  vim.api.nvim_create_autocmd('User', {
    once = true,
    pattern = 'GpDone',
    callback = function(event)
      vim.bo[event.buf].filetype = filetype
    end,
  })
end

function fn.ai_conv(cmd, text)
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
      vim.cmd[[tabe]]

      vim.bo.filetype = 'markdown'
      vim.bo.bufhidden = 'wipe'

      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

      vim.cmd('%Gp'..cmd..' '..filetype)

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
--{{{ Workspace
local function get_workspace_file_path(tabpage)
  return fn.get_workspace_dir(tabpage).."/"..vim.g.workspace_file_name
end

local function load_workspace(tabpage)
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
    local tabpage = vim.api.nvim_get_current_tabpage()
    fn.set_tab_cwd(tabpage, workspace_path)
    load_workspace()
  end
end
--}}}

return fn
