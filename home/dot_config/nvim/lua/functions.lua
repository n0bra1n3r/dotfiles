_G.fn = {}

-- helpers --

local function pick_window(exclude)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local win_ids = vim.api.nvim_tabpage_list_wins(tabpage)

  local selectable = vim.tbl_filter(function(id)
    if id == vim.api.nvim_get_current_win() then
      return false
    end

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

-- shell --

function _G.fn.save_dot_files()
  vim.cmd[[AsyncRun -strip chezmoi apply --exclude=scripts --force --source-path "%"]]
end

-- nvim --

function _G.fn.close_buffer()
  if vim.fn.tabpagenr() > 1 then
    vim.cmd[[tabclose]]
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
        "lazy",
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
  local picked = pick_window()

  if picked ~= nil then
    vim.api.nvim_set_current_win(picked)
  end
end

function _G.fn.set_shell_title()
  if #vim.bo.buftype == 0 then
    local file_name = vim.fn.expand("%:t")

    if #file_name > 0 then
      vim.o.titlestring = "nvim - "..file_name
    end
  end
end

-- lualine --

local is_job_in_progress = false

function _G.fn.get_is_job_in_progress()
  return is_job_in_progress
end

function _G.fn.set_is_job_in_progress(value)
  is_job_in_progress = value
  vim.cmd[[redrawtabline]]
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
