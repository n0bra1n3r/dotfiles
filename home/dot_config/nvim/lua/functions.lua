-- vim: foldmethod=marker foldlevel=0 foldenable

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
local is_git_dir = false
local git_branch = nil
local has_git_remote = false
local git_local_change_count = 0
local git_remote_change_count = 0

function fn.refresh_git_change_info()
  if is_git_dir then
    git_local_change_count = tonumber(vim.fn.system(string.format("git rev-list --right-only --count %s@{upstream}...%s", git_branch, git_branch)))
    git_remote_change_count = tonumber(vim.fn.system(string.format("git rev-list --left-only --count %s@{upstream}...%s", git_branch, git_branch)))
  end
end

function fn.refresh_git_info()
  vim.fn.system[[git rev-parse --is-inside-work-tree]]
  is_git_dir = vim.v.shell_error == 0

  if is_git_dir then
    git_branch = vim.fn.system[[git branch --show-current]]:match[[(.-)%s*$]]

    vim.fn.system("git show-branch remotes/origin/"..git_branch)
    has_git_remote = vim.v.shell_error == 0
  end

  fn.refresh_git_change_info()
end

function fn.is_git_dir()
  return is_git_dir
end

function fn.get_git_branch()
  return git_branch
end

function fn.has_git_remote()
  return has_git_remote
end

function fn.git_local_change_count()
  return git_local_change_count
end

function fn.git_remote_change_count()
  return git_remote_change_count
end

function fn.open_commit_log()
  fn.make_terminal_app("commits", "tigrc")
  vim.cmd[[FloatermShow commits]]
end
--}}}

--{{{ Files
function fn.delete_file()
  vim.fn.delete(vim.fn.expand('%:p'))
  vim.cmd[[bwipeout!]]
end

function fn.open_file()
  local rel_dir = vim.fn.expand("%:h").."/"
  local path = vim.fn.input("open path: ", rel_dir, "dir")

  if #path == 0 or
      path == rel_dir or
      path.."/" == rel_dir then
    return
  end

  rel_dir = vim.fn.fnamemodify(path, ":h")
  if #vim.fn.glob(rel_dir) == 0 then
    vim.cmd(string.format("!bash -c 'mkdir -p \"%s\"'", rel_dir))
  end
  vim.cmd(string.format("edit %s", path))
end

function fn.move_file()
  local rel_file = vim.fn.expand("%")
  local path = vim.fn.input("move path: ", rel_file, "file")

  if #path == 0 or
      path == rel_file then
    return
  end

  local rel_dir = vim.fn.fnamemodify(path, ":h")
  if #vim.fn.glob(rel_dir) == 0 then
    vim.cmd(string.format("!bash -c 'mkdir -p \"%s\"'", rel_dir))
  end
  vim.cmd(string.format("saveas %s | call delete(expand('#')) | bwipeout #", path))
end

function fn.open_file_tree()
  fn.make_terminal_app("files", "brootrc")
  vim.cmd[[FloatermShow files]]
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

local prev_line

function fn.trigger_completion()
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

function fn.end_completion()
  require"cmp".close()
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

function fn.close_buffer()
  if vim.fn.tabpagenr() > 1 then
    vim.cmd[[tabclose]]
  elseif vim.fn.winnr("$") > 1 then
    vim.cmd[[close]]
  else
    vim.cmd[[bwipeout]]
  end
end

function fn.edit_file(mode, path)
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
        "floaterm",
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

--{{{ Shell
function fn.set_shell_title()
  if #vim.bo.buftype == 0 then
    local file_name = vim.fn.expand("%:t")

    if #file_name > 0 then
      vim.o.titlestring = "nvim - "..file_name
    end
  end
end
--}}}

--{{{ Tasks
local is_job_in_progress = false

function fn.get_is_job_in_progress()
  return is_job_in_progress
end

function fn.set_is_job_in_progress(value)
  is_job_in_progress = value
  vim.cmd[[redrawtabline]]
end

function fn.project_status()
  return vim.g.asynctasks_profile
end

local queued_task

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("queued_task_runner", { clear = true }),
  pattern = "AsyncRunStop",
  callback = function()
    if queued_task ~= nil then
      vim.cmd("AsyncTask "..queued_task)
      queued_task = nil
    end
  end,
})

function fn.run_task(name)
  if not fn.get_is_job_in_progress() then
    queued_task = nil
    vim.cmd("AsyncTask "..name)
  else
    queued_task = name
  end
end

function fn.project_check()
  fn.run_task("project-check")
end

function fn.save_dot_files()
  fn.run_task("apply-config")
end
--}}}

--{{{ Terminal
function fn.open_terminal(command)
  local width = math.ceil(vim.o.columns)
  local height = math.ceil(vim.o.lines * 0.3)
  local position = "bottom"
  local bufnr = fn.make_terminal_app("terminal", "floatermrc", height, width, position, false, false)
  if bufnr ~= nil then
    local is_zoomed = false
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<Enter>", [[i]],
      { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "z", [[]],
      { noremap = true, silent = true,
        callback = function()
          local new_width
          local new_height
          local new_position
          if not is_zoomed then
            new_width = math.ceil(vim.o.columns * 0.9)
            new_height = math.ceil(vim.o.lines * 0.9)
            new_position = "center"
          else
            new_width = width
            new_height = height
            new_position = position
          end
          is_zoomed = not is_zoomed
          vim.api.nvim_create_autocmd("BufEnter", {
            once = true,
            buffer = bufnr,
            callback = fn.vim_defer[[startinsert]],
          })
          vim.cmd("FloatermUpdate"
            .." --position="..new_position
            .." --width="
            ..tostring(new_width)
            .." --height="
            ..tostring(new_height))
        end,
      })
  end
  if command ~= nil then
    is_terminal_in_insert_mode = true
    vim.cmd(string.format('set ssl | exec "FloatermSend --name=terminal %s" | set nossl', command))
  end
  vim.cmd[[FloatermShow terminal]]
end

function fn.make_terminal_app(name, rcfile, height, width, position, autodismiss, autoinsert)
  if vim.fn["floaterm#terminal#get_bufnr"](name) == -1 then
    local bufnr = vim.fn["floaterm#new"](0,
      "bash --rcfile ~/.dotfiles/"..rcfile,
      { [''] = '' },
      {
        silent = 1,
        name = name,
        title = name,
        height = height or math.ceil(vim.o.lines * 0.9),
        width = width or math.ceil(vim.o.columns * 0.9),
        position = position or "center",
      })
    local group = vim.api.nvim_create_augroup("conf_terminal_apps", { clear = true })
    if autoinsert == nil or autoinsert then
      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        buffer = bufnr,
        callback = fn.vim_defer[[startinsert]]
      })
    end
    if autodismiss == nil or autodismiss then
      vim.api.nvim_create_autocmd("TermLeave", {
        group = group,
        buffer = bufnr,
        callback = function()
          vim.cmd("FloatermHide "..name)
        end,
      })
    end
    return bufnr
  end
end
--}}}

--{{{ Utilities
function fn.get_map_expr(key)
  return string.format("v:count || mode(1)[0:1] == 'no' ? '%s' : 'g%s'", key, key)
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
--}}}

--{{{ Workspace
function fn.get_workspace_dir()
  local folder = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:.")

  if not fn.is_git_dir() then
    return folder
  end

  local branch = fn.get_git_branch()

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

function fn.switch_workspace(path)
  vim.cmd[[FloatermKill!]]
  vim.cmd("Prosession "..path)
end
--}}}
