local M = {}

local namespace = "search-result"

local api = vim.api
local job = require "plenary.job"

function M._on_buf_delete()
  local bufid = vim.fn.bufnr("%")
  M.buffers[bufid] = nil
end

function M._on_buf_write()
  for _, info in pairs(M.buffers) do
    -- TODO
  end
end

function M._on_vim_leave()
  for bufid, _ in pairs(M.buffers) do
    api.nvim_buf_delete(bufid, { force = true })
  end
end

local function scroll_up_expr(key)
  return "getpos('.')[1]<=2?'3<C-y>"..key.."':'"..key.."'"
end

local function create_canvas(win_create_cmd, search_term)
  api.nvim_command(win_create_cmd)
  local winid = api.nvim_get_current_win()
  local bufid = api.nvim_get_current_buf()

  api.nvim_buf_set_name(bufid, search_term)
  api.nvim_buf_set_option(bufid, "bufhidden", "wipe")
  api.nvim_buf_set_option(bufid, "buftype", "nofile")
  api.nvim_buf_set_option(bufid, "filetype", "search")
  api.nvim_win_set_option(winid, "number", false)
  api.nvim_win_set_option(winid, "signcolumn", "auto:9")
  api.nvim_buf_set_option(bufid, "swapfile", false)

  -- ensure first result file name is visible
  api.nvim_buf_set_keymap(bufid, "", "<Up>", scroll_up_expr("<Up>"), {
    expr = true,
    noremap = true,
  })
  api.nvim_buf_set_keymap(bufid, "n", "k", scroll_up_expr("k"), {
    expr = true,
    noremap = true,
  })
  api.nvim_buf_set_keymap(bufid, "n", "gg", "gg2<C-y>", {
    noremap = true,
  })
  api.nvim_buf_set_keymap(bufid, "v", "k", scroll_up_expr("k"), {
    expr = true,
    noremap = true,
  })
  api.nvim_buf_set_keymap(bufid, "v", "gg", "gg2<C-y>", {
    noremap = true,
  })

  api.nvim_command[[augroup search_on_buf_delete]]
  api.nvim_command[[autocmd BufDelete <buffer> lua require'search'._on_buf_delete()]]
  api.nvim_command[[augroup end]]

  api.nvim_command[[augroup search_on_buf_write]]
  api.nvim_command[[autocmd BufWriteCmd <buffer> lua require'search'._on_buf_write()]]
  api.nvim_command[[augroup end]]

  api.nvim_command[[augroup search_on_vim_leave]]
  api.nvim_command[[autocmd!]]
  api.nvim_command("autocmd VimLeavePre * lua require'search'._on_vim_leave()")
  api.nvim_command[[augroup end]]

  return bufid
end

local function init_info(bufid, search_term)
  if M.buffers == nil then
    M.buffers = {}
  end

  if M.buffers[bufid] == nil then
    M.buffers[bufid] = {
      search_term = search_term,
      file_table = {},
      line_table = {},
      ncol_width = 0,
    }
  end
end

local function get_info(bufid)
  return M.buffers[bufid]
end

local function get_line_text_parts(line)
  local format = vim.o.grepformat

  local part_index = {}
  local i = 0
  local pattern = string.gsub(format, "%%(%a)", function(s)
    -- convert grepformat format token to regex
    i = i + 1
    part_index[s] = i
    return ({
      f = "(.+)",
      l = "(%d+)",
      c = "(%d+)",
      m = "(.+)",
    })[s]
  end)

  local part_array = {select(3, string.find(line, pattern))}

  local part_table = {}
  for key, i in pairs(part_index) do
    part_table[key] = part_array[i]
  end
  return part_table
end

local function render_file_name(bufid, line, file_part)
  api.nvim_buf_set_extmark(bufid, api.nvim_create_namespace(namespace), line, 0, {
    id = line + 1,
    virt_lines = { {{ " " }}, {{ file_part..":", "Directory" }} },
    virt_lines_above = true,
    virt_lines_leftcol = true,
  })
end

local function place_sign(group, bufid, line, label)
  for _, entry in ipairs(vim.fn.sign_getplaced(bufid, { group = group })) do
    for i, sign in ipairs(entry.signs) do
      vim.fn.sign_unplace(sign.group)
      vim.fn.sign_undefine(sign.name)
    end
  end
  for _, entry in ipairs(vim.fn.sign_getplaced(bufid, { group = "*", lnum = line + 1 })) do
    for i, sign in ipairs(entry.signs) do
      vim.fn.sign_unplace(sign.group)
      vim.fn.sign_undefine(sign.name)
    end
  end

  for i = 0, math.floor(#label / 2) do
    local index = i * 2
    local final = index + 1
    if final >= #label then
      final = final - 1
    end
    local name = group..":"..tostring(i)
    vim.fn.sign_define(name, {
      text = string.sub(label, index + 1, final + 1),
      texthl = "LineNr",
    })
    vim.fn.sign_place(i + 1, group, name, bufid, { lnum = line + 1 })
  end
end

local function get_sign_label(text, padding)
  local result = text
  for i = 1, padding do
    result = " "..result
  end
  return result
end

local function render_line_number(bufid, line, line_part)
  local info = get_info(bufid)
  local group = namespace..tostring(line)
  if #line_part <= info.ncol_width then
    local label = get_sign_label(line_part, info.ncol_width - #line_part)
    place_sign(group, bufid, line, label)
  else
    for index, parts_list in ipairs(info.line_table) do
      local prev_line = index - 1
      local prev_line_part = parts_list[1].l
      local prev_group = namespace..tostring(prev_line)
      local prev_label = get_sign_label(prev_line_part, #line_part - #prev_line_part)
      place_sign(prev_group, bufid, prev_line, prev_label)
    end
    place_sign(group, bufid, line, line_part)
  end
end

local function set_line_string(bufid, line, line_string)
  if line_string ~= nil then
    api.nvim_buf_set_lines(bufid, line, line, true, { line_string })
  else
    api.nvim_buf_set_lines(bufid, line, line + 1, true, {})
  end
end

local function clear_modifications(bufid)
  vim.bo[bufid].undolevels = -1
  api.nvim_command[[exec "normal! a \<BS>\<Esc>"]]
  vim.bo[bufid].undolevels = 1000
  vim.bo[bufid].modified = false
end

local function render_result(bufid, line, parts)
  local info = get_info(bufid)
  local next_line = line
  if info.file_table[parts.f] == nil then
    set_line_string(bufid, line, parts.m)
    render_file_name(bufid, line, parts.f)
    render_line_number(bufid, line, parts.l, info)
    next_line = line + 1
  elseif info.file_table[parts.f][parts.l] == nil then
    set_line_string(bufid, line, parts.m)
    render_line_number(bufid, line, parts.l, info)
    next_line = line + 1
  end

  --[[
  local hl_col_index = tonumber(parts.c) - 1
  local hl_col_final = hl_col_index + #info.search_term
  api.nvim_buf_add_highlight(
    bufid,
    api.nvim_create_namespace(namespace),
    "Search",
    next_line - 1,
    hl_col_index,
    hl_col_final)
  ]]

  return next_line
end

local function save_modification(bufid, line)
  local info = M.buffers[bufid]
  -- TODO
end

local function watch_modifications(bufid)
  api.nvim_buf_attach(bufid, false, {
	  on_bytes = vim.schedule_wrap(function(
        _, bufid, _,
        first_line, first_line_col, buffer_offset,
        line_offset, last_line_col, change_len,
        new_line_offset, new_last_line_col, new_change_len)
      local win = vim.fn.bufwinid(bufid)
      local info = M.buffers[bufid]

      if line_offset > new_line_offset then
        -- lines were removed
        if first_line_col ~= 0 or last_line_col ~= 0 then
          save_modification(bufid, first_line)
        end
        for line = first_line, first_line + new_line_offset do
          local line_string = info.line_table[line + 1][1].l
          render_line_number(bufid, line, line_string)
        end
      elseif line_offset < new_line_offset then
        -- lines were added
        local line_count = api.nvim_buf_line_count(bufid)
        local start_line = math.max(0, first_line - 1)
        local last_line = math.min(line_count - 1, first_line + new_line_offset * 2)
        local line_diff = math.max(0, line_count - #info.line_table)
        local skip_line = line_diff
        local text_line = start_line

        for line = start_line, last_line do
          local line_offset = line - start_line
          local line_count = new_line_offset - line_diff
          
          if line_offset <= line_count or skip_line == 0 then
            -- render line numbers only when the resulting number of line
            -- numbers equals the number of search results
            local line_string = info.line_table[text_line + 1][1].l
            render_line_number(bufid, line, line_string)
            save_modification(bufid, line)
            text_line = text_line + 1
          elseif line_offset > line_count then
            skip_line = skip_line - 1
          end
        end
        if line_diff ~= 0 then
          -- offset following line numbers by number of blank lines added
          for line = last_line + 1, line_count - 1 do
            local line_string = info.line_table[text_line + 1][1].l
            render_line_number(bufid, line, line_string)
            text_line = text_line + 1
          end
          -- always render the first file name at the top
          if first_line == 0 then
            local file_string = info.line_table[first_line + 1][1].f
            render_file_name(bufid, first_line, file_string)
            api.nvim_command[[exec "normal 2\<C-y>"]]
          end
        end
      else
        -- lines were changed
        save_modification(bufid, first_line)
      end
		end),
  })
end

local function render_status(bufid)
  local info = get_info(bufid)

  local total_file_count = 0
  for _, _ in pairs(info.file_table) do
    total_file_count = total_file_count + 1
  end

  local total_line_count = 0
  for _, parts_list in pairs(info.line_table) do
    total_line_count = total_line_count + #parts_list
  end

  local status_string = "'"..info.search_term.."' | "
    ..tostring(total_line_count)
    .." results | "
    ..tostring(total_file_count)
    .." files"

  api.nvim_buf_set_name(bufid, status_string)
end

local function render_window(bufid, line, parts)
  local info = get_info(bufid)
  local win = vim.fn.bufwinid(bufid)
  local win_height = api.nvim_win_get_height(win)
  local res_height = #info.line_table + #info.file_table * 2

  if res_height <= win_height and res_height % 16 == 0  then
    api.nvim_command[[redraw]]

    local first_line = info.line_table[1]
    local first_col = first_line == nil
      and tonumber(parts.c) - 1
      or tonumber(first_line[1].c) - 1

    api.nvim_win_set_cursor(win, { 1, first_col })
    if first_line == nil then
      api.nvim_command[[exec "normal 2\<C-y>"]]
    end
  elseif res_height > win_height and res_height % 32 == 0 then
    api.nvim_command[[redraw]]
  end
end

local function get_command(search_term, globs)
  local grep = vim.fn.split(vim.o.grepprg)
  local cmd = grep[1]
  local args = {select(2, unpack(grep))}
  for _, glob in ipairs(globs) do
    table.insert(args, "--glob")
    table.insert(args, glob)
  end
  table.insert(args, search_term)
  return cmd, args
end

function M.run(win_create_cmd, search_term, globs)
  local cmd, args = get_command(search_term, globs)
  local cwd = vim.fn.getcwd()
  local win = api.nvim_get_current_win()

  local bufid = create_canvas(win_create_cmd, search_term)
  init_info(bufid, search_term)

  render_status(bufid)

  local line = 0
  job:new({
    command = cmd,
    args = args,
    cwd = cwd,
    enable_recording = false,
    interactive = false,
    on_stdout = vim.schedule_wrap(function(_, line_text, _)
      local info = get_info(bufid)
      local parts = get_line_text_parts(line_text)

      line = render_result(bufid, line, parts)
      render_window(bufid, line, parts)

      if info.file_table[parts.f] == nil then
        info.file_table[parts.f] = {}
      end
      info.file_table[parts.f][parts.l] = line
      if info.line_table[line] == nil then
        info.line_table[line] = {}
      end
      table.insert(info.line_table[line], parts)

      info.ncol_width = math.max(info.ncol_width, #parts.l)

      render_status(bufid)
    end),
    on_exit = vim.schedule_wrap(function(_, code)
      set_line_string(bufid, line, nil)
      clear_modifications(bufid)
      watch_modifications(bufid)
      api.nvim_buf_set_option(bufid, "buftype", "acwrite")
    end),
  }):start()
end

return M
