local M = {}

local api = vim.api
local job = require "plenary.job"

-- Helper functions --

local function get_scroll_up_expr(key)
  return string.format("getpos('.')[1]<=2?'%s2<C-y>':'%s'", key, key)
end

local function get_sign_group(namespace, file_name, line_number)
  return string.format("%s-%s:%s", namespace, file_name, line_number)
end

local function get_sign_name(group, offset)
  return string.format("%s:%d", group, offset)
end

local function get_line_number_label(text, padding)
  local result = text

  for i = 1, padding do
    result = " "..result
  end

  return result
end

local function get_search_command(search_term, search_args)
  local grep = vim.fn.split(vim.o.grepprg)
  local cmd = grep[1]
  local argList = {select(2, unpack(grep))}

  if search_args ~= nil then
    for _, arg in ipairs(search_args) do
      table.insert(argList, arg)
    end
  end

  if search_term ~= nil then
    table.insert(argList, search_term)
  end

  return cmd, argList
end

local function parse_result(result_line)
  local format = vim.o.grepformat

  local part_index = {}
  local i = 0
  local pattern = string.gsub(format, "%%(%a)", function(s)
    -- convert grepformat format token to regex
    part_index[s] = i
    i = i + 1
    return ({
      f = "(.+)",
      l = "(%d+)",
      c = "(%d+)",
      m = "(.+)",
    })[s]
  end)

  local part_array = {select(3, string.find(result_line, pattern))}

  local part_table = {}
  for s, i in pairs(part_index) do
    local key = ({
      f = "file_name",
      l = "line_number",
      c = "col_number",
      m = "line_text",
    })[s]
    part_table[key] = part_array[i + 1]
  end

  return part_table
end

-- Global config --

api.nvim_command[[augroup search_on_vim_leave]]
api.nvim_command[[autocmd!]]
api.nvim_command[[autocmd VimLeavePre * lua require"search"._on_vim_leave()]]
api.nvim_command[[augroup end]]

api.nvim_command[[highlight SearchResult gui=bold cterm=bold]]

-- Initialization --

local function create_buffer_if_needed()
  local bufnr = api.nvim_get_current_buf()

  if M.buffers == nil or M.buffers[bufnr] == nil then
    if #api.nvim_buf_get_name(bufnr) > 0 or
        api.nvim_buf_line_count(bufnr) > 0 then
      api.nvim_command[[keepjumps enew]]

      return api.nvim_get_current_buf()
    end

    return bufnr
  end
end

local function get_buffer()
  local bufnr = create_buffer_if_needed()

  if bufnr ~= nil then
    local winid = api.nvim_get_current_win()

    -- options
    api.nvim_buf_set_name(bufnr, "search")
    api.nvim_buf_set_option(bufnr, "filetype", "search")
    api.nvim_buf_set_option(bufnr, "swapfile", false)
    api.nvim_win_set_option(winid, "number", false)
    api.nvim_win_set_option(winid, "signcolumn", "auto:9")

    -- navigation
    api.nvim_buf_set_keymap(bufnr, "i", "<Down>", [[<cmd>lua require"search".next_line()<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "i", "<Up>", get_scroll_up_expr[[<cmd>lua require"search".prev_line()<CR>]], {
      noremap = true,
      expr = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "<Down>", [[<cmd>lua require"search".next_line(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "<Up>", get_scroll_up_expr[[<cmd>lua require"search".prev_line(vim.v.count)<CR>]], {
      noremap = true,
      expr = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "j", [[<cmd>lua require"search".next_line(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "k", get_scroll_up_expr[[<cmd>lua require"search".prev_line(vim.v.count)<CR>]], {
      noremap = true,
      expr = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "G", [[<cmd>lua require"search".last_result()<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "m", [[<cmd>lua require"search".next_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "M", [[<cmd>lua require"search".prev_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "gg", [[<cmd>lua require"search".first_result()<CR>2<C-y>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "v", "<Up>", get_scroll_up_expr[[<Up>]], {
      noremap = true,
      expr = true,
    })
    api.nvim_buf_set_keymap(bufnr, "x", "k", get_scroll_up_expr[[k]], {
      noremap = true,
      expr = true,
    })
    api.nvim_buf_set_keymap(bufnr, "x", "m", [[<cmd>lua require"search".next_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "x", "M", [[<cmd>lua require"search".prev_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "x", "gg", [[gg2<C-y>]], {
      noremap = true,
    })

    -- text objects
    api.nvim_buf_set_keymap(bufnr, "n", "gM", [[<cmd>lua require"search".select_prev_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "n", "gm", [[<cmd>lua require"search".select_next_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "o", "gM", [[<cmd>lua require"search".select_prev_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "o", "gm", [[<cmd>lua require"search".select_next_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "x", "gM", [[<cmd>lua require"search".select_prev_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })
    api.nvim_buf_set_keymap(bufnr, "x", "gm", [[<cmd>lua require"search".select_next_result(vim.v.count)<CR>]], {
      noremap = true,
      silent = true,
    })

    -- autocommands
    api.nvim_command[[augroup search_autocommands]]
    api.nvim_command[[autocmd BufDelete <buffer> lua require"search"._on_buf_delete(tonumber(vim.fn.expand"<abuf>"))]]
    api.nvim_command[[autocmd BufEnter <buffer> lua require"search"._on_buf_enter(tonumber(vim.fn.expand"<abuf>"))]]
    api.nvim_command[[autocmd BufLeave <buffer> lua require"search"._on_buf_leave(tonumber(vim.fn.expand"<abuf>"))]]
    api.nvim_command[[autocmd BufWriteCmd <buffer> lua require"search"._on_buf_write(tonumber(vim.fn.expand"<abuf>"))]]
    api.nvim_command[[autocmd CursorMoved,CursorMovedI <buffer> lua require"search"._on_cursor_moved(tonumber(vim.fn.expand"<abuf>"))]]
    api.nvim_command[[augroup end]]
  end

  return api.nvim_get_current_buf()
end

-- Updating --

local function push_result(bufnr, line, result)
  local info = M.buffers[bufnr]

  result.is_first_line = false
  result.is_first_col = false

  local file_info = info.file_table[result.file_name]
  if file_info == nil then
    line = line + 1

    info.file_table[result.file_name] = {
      [result.line_number] = line + 1,
    }

    result.is_first_line = true
    result.is_first_col = true
  elseif file_info[result.line_number] == nil then
    line = line + 1

    file_info[result.line_number] = line + 1

    result.is_first_col = true
  end

  local results = info.result_array[line + 1]
  if results == nil then
    info.result_array[line + 1] = { result }
  else
    table.insert(results, result)
  end

  info.line_array[line + 1] = {
    file_name = result.file_name,
    line_number = result.line_number,
  }

  return line
end

local function results_at(bufnr, line)
  local info = M.buffers[bufnr]

  if #info.line_array > 0 then
    local line_info = info.line_array[line + 1]
    local line_index = info.file_table[line_info.file_name][line_info.line_number]

    return info.result_array[line_index]
  end

  return {}
end

local function is_current_search(info)
  local current_info = M.buffers[info.bufnr]
  return current_info ~= nil and current_info.search_id == info.search_id
end

local function reset_search(bufnr, search_term, search_args)
  if M.buffers == nil then
    M.buffers = {}
  end

  local info = M.buffers[bufnr]

  if info ~= nil then
    api.nvim_command[[echon]]

    if info.job ~= nil and not info.job.is_shutdown then
      info.job:shutdown()
      info.job = nil
    end

    if #info.line_array > 0 then
      for line = 0, api.nvim_buf_line_count(bufnr) - 1 do
        local line_info = info.line_array[line + 1]
        local sign_group = get_sign_group(
          info.namespace,
          line_info.file_name,
          line_info.line_number)

        if vim.fn.sign_unplace(sign_group) == 0 then
          for offset = 0, math.floor(info.sign_width / 2) do
            vim.fn.sign_undefine(get_sign_name(sign_group, offset))
          end
        end
      end

      api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
      api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    end
  end

  local cmd, args = get_search_command(search_term, search_args)

  M.buffers[bufnr] = {
    -- Search info
    search_id = info and info.search_id + 1 or 1,
    search_term = search_term,
    -- Job info
    args = args,
    cmd = cmd,
    cwd = vim.fn.getcwd(),
    job = nil,
    -- Buffer info
    bufnr = bufnr,
    cursor_line = 0,
    namespace = string.format("search-%d", bufnr),
    sign_width = 0,
    -- Result info
    file_table = {},
    line_array = {},
    result_array = {},
    -- State info
    is_editing = false,
    is_searching = false,
  }

  api.nvim_buf_set_option(bufnr, "buftype", "nofile")

  return M.buffers[bufnr]
end

-- Event callbacks --

function M._on_prompt_input(search_args)
  M.run(vim.fn.getcmdline(), search_args)
end

function M._on_cursor_moved(bufnr)
  local info = M.buffers[bufnr]

  local line = vim.fn.line"." - 1

  if info.cursor_line ~= line then
    local prev_info = info.line_array[info.cursor_line + 1]
    local prev_group = get_sign_group(info.namespace, prev_info.file_name, prev_info.line_number)

    local curr_info = info.line_array[line + 1]
    local curr_group = get_sign_group(info.namespace, curr_info.file_name, curr_info.line_number)

    for offset = 0, math.floor(info.sign_width / 2) do
      local prev_name = get_sign_name(prev_group, offset)
      vim.fn.sign_define(prev_name, { texthl = "LineNr" })

      local curr_name = get_sign_name(curr_group, offset)
      vim.fn.sign_define(curr_name, { texthl = "CursorLineNr" })
    end

    info.cursor_line = line
  end
end

function M._on_buf_delete(bufnr)
  if M.buffers ~= nil and M.buffers[bufnr] ~= nil then
    reset_search(bufnr)
    M.buffers[bufnr] = nil
  end
end

function M._on_buf_enter(bufnr)
  local info = M.buffers and M.buffers[bufnr]

  if info ~= nil then
    info.is_editing = true
  end
end

function M._on_buf_leave(bufnr)
  local info = M.buffers and M.buffers[bufnr]

  if info ~= nil then
    info.is_editing = false
  end
end

function M._on_buf_write(bufnr)
  -- TODO
end

function M._on_vim_leave()
  for bufnr, _ in pairs(M.buffers) do
    api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Rendering --

local function render_status(bufnr)
  local info = M.buffers[bufnr]

  local total_file_count = vim.tbl_count(info.file_table)
  local total_line_count = #info.line_array

  local status_string = string.format(
    "<%s> %dl:%df",
    info.search_term,
    total_line_count,
    total_file_count)

  api.nvim_buf_set_name(bufnr, status_string)

  api.nvim_command[[redrawstatus]]
end

local function render_file_name(bufnr, line, file_name)
  local info = M.buffers[bufnr]

  local namespace = api.nvim_create_namespace(info.namespace.."-"..file_name)

  for _, item in ipairs(api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, {})) do
    api.nvim_buf_del_extmark(bufnr, namespace, item[1])
  end

  if line >= 0 then
    api.nvim_buf_set_extmark(bufnr, namespace, line, 0, {
      id = line + 1,
      virt_lines = { {{ " " }}, {{ string.format("%s:", file_name), "Directory" }} },
      virt_lines_above = true,
      virt_lines_leftcol = true,
    })

    if line == 0 then
      api.nvim_command[[exec "normal! 2\<C-y>"]]
    end
  end
end

local function render_line_text(bufnr, line, line_text)
  api.nvim_buf_set_lines(bufnr, line, line > 0 and line or line + 1, true, { line_text })
end

local function render_line_number_sign(bufnr, line, group, label)
  vim.fn.sign_unplace(group)

  if #label % 2 == 0 then
    label = " "..label
  end

  for i = 0, math.floor(#label / 2) do
    local index = i * 2
    local final = index + 1

    if final >= #label then
      final = final - 1
    end

    local name = get_sign_name(group, i)

    vim.fn.sign_define(name, {
      text = string.sub(label, index + 1, final + 1),
      texthl = line == 0 and "CursorLineNr" or "LineNr",
    })
    vim.fn.sign_place(i + 1, group, name, bufnr, { lnum = line + 1 })
  end

  return #label
end

local function render_line_number(bufnr, line, file_name, line_number)
  local info = M.buffers[bufnr]

  local group = get_sign_group(info.namespace, file_name, line_number)

  if #line_number <= info.sign_width then
    local label = get_line_number_label(line_number, info.sign_width - #line_number)
    render_line_number_sign(bufnr, line, group, label)
  else
    for i, line_info in ipairs(info.line_array) do
      local prev_line = i - 1
      local prev_group = get_sign_group(info.namespace, line_info.file_name, line_info.line_number)
      local prev_label = get_line_number_label(line_info.line_number, #line_number - #line_info.line_number)
      render_line_number_sign(bufnr, prev_line, prev_group, prev_label)
    end

    info.sign_width = render_line_number_sign(bufnr, line, group, line_number)
  end
end

local function render_result(bufnr, line, result)
  local info = M.buffers[bufnr]

  if result.is_first_col then
    render_line_text(bufnr, line, result.line_text)
    render_line_number(bufnr, line, result.file_name, result.line_number, info)
  end

  if result.is_first_line then
    render_file_name(bufnr, line, result.file_name)
  end
end

local function highlight_results(bufnr, line)
  local info = M.buffers[bufnr]

  local namespace = api.nvim_create_namespace(info.namespace.."-results")

  for _, result in ipairs(info.result_array[line + 1]) do
    local col_start = tonumber(result.col_number) - 1
    local col_end = col_start + #info.search_term

    api.nvim_buf_add_highlight(
      bufnr,
      namespace,
      "SearchResult",
      line,
      col_start,
      col_end)
    end
end

-- Change tracking --

local function save_modification(bufnr, line)
  -- TODO
  local info = M.buffers[bufnr]
  local text = api.nvim_buf_get_lines(bufnr, line, line + 1, {})[1]
end

local function watch_modifications(bufnr)
  local info = M.buffers[bufnr]

  api.nvim_buf_attach(bufnr, false, {
	  on_bytes = vim.schedule_wrap(function(
        _, bufnr, _,
        first_line, first_line_col, buffer_offset,
        line_offset, last_line_col, change_len,
        new_line_offset, new_last_line_col, new_change_len)
      if not is_current_search(info) then
        return true
      end

      if line_offset > new_line_offset then
        -- lines were removed

        local last_line = first_line + line_offset - 1

        if first_line_col ~= 0 or last_line_col ~= 0 then
          save_modification(bufnr, first_line)
        end

        for _ = first_line + 1, last_line + 1 do
          local line_info = info.line_array[first_line + 1]

          table.remove(info.line_array, first_line + 1)

          if line_info.file_name ~= nil then
            local line_table = info.file_table[line_info.file_name]
            line_table[line_info.line_number] = nil
            if vim.tbl_count(line_table) == 0 then
              render_file_name(bufnr, -1, line_info.file_name)
            end
          end
        end
      elseif line_offset < new_line_offset then
        -- lines were added

        local next_line = first_line + line_offset + 1
        local last_line = first_line + new_line_offset - 1

        local prev_info = info.line_array[first_line]
        local next_info = info.line_array[next_line]

        if (prev_info == nil or prev_info.line_number ~= nil) and
            (next_info == nil or next_info.line_number ~= nil) then
          local first_index = prev_info
            and math.min(info.file_table[prev_info.file_name][prev_info.line_number] + 1, #info.result_array)
            or 1

          local last_index = next_info
            and math.max(info.file_table[next_info.file_name][next_info.line_number] - 1, 1)
            or #info.result_array

          if first_index <= last_index then
            local index = first_index

            for line = first_line, last_line + 1 do
              local result = info.result_array[index][1]
              local line_table = info.file_table[result.file_name]

              line_table[result.line_number] = index

              render_line_number(bufnr, line, result.file_name, result.line_number)

              local min_index = index

              for _, index in pairs(line_table) do
                min_index = math.min(min_index, index)
              end

              if index == min_index then
                render_file_name(bufnr, line, result.file_name)
              end

              if index <= last_index then
                table.insert(info.line_array, line + 1, {
                  file_name = result.file_name,
                  line_number = result.line_number,
                })

                local line_text = api.nvim_buf_get_lines(bufnr, line, line + 1, true)[1]

                if line_text ~= result.line_text then
                  save_modification(bufid, line)
                end
              end

              index = index + 1

              if index > #info.result_array then
                break
              end
            end
          else
            for line = first_line, last_line do
              table.insert(info.line_array, line + 1, {})
            end
          end
        else
          for line = first_line, last_line do
            table.insert(info.line_array, line + 1, {})
          end
        end
      else
        -- lines were changed

        save_modification(bufnr, first_line)
      end
    end),
  })
end

-- Interface --

local function finish_search(bufnr)
  local info = M.buffers[bufnr]

  local start_line = api.nvim_buf_line_count(bufnr)
  local end_line = #info.result_array - 1

  for line = start_line, end_line do
    for _, result in ipairs(info.result_array[line + 1]) do
      render_result(bufnr, line, result)
    end

    highlight_results(bufnr, line)
  end

  api.nvim_buf_set_option(bufnr, "undolevels", -1)
  api.nvim_command[[exec "normal! i \<BS>\<Esc>"]]
  api.nvim_buf_set_option(bufnr, "undolevels", 1000)
  api.nvim_buf_set_option(bufnr, "modified", false)
  api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
  api.nvim_win_set_cursor(winid, { 1, 0 })

  api.nvim_command[[redraw]]

  watch_modifications(bufnr)
end

function M.prompt(prompt, search_args)
  api.nvim_command[[augroup search_prompt_watcher]]
  api.nvim_command[[autocmd!]]

  if search_args == nil then
    api.nvim_command[[autocmd CmdlineChanged * lua require"search"._on_prompt_input()]]
  else
    api.nvim_command(string.format([[
      autocmd CmdlineChanged * lua require"search"._on_prompt_input("%s")
    ]], search_args))
  end

  api.nvim_command[[augroup end]]

  local bufnr = api.nvim_get_current_buf()
  local info = M.buffers and M.buffers[bufnr]

  if info then
    api.nvim_command[[bwipeout]]
  end

  search_term = vim.fn.input {
    default = info and info.search_term,
    prompt = prompt,
  }

  api.nvim_command[[autocmd! search_prompt_watcher]]

  bufnr = api.nvim_get_current_buf()
  info = M.buffers and M.buffers[bufnr]

  if info ~= nil then
    if #search_term == 0 then
      api.nvim_command[[bwipeout]]
    else
      if not info.is_searching then
        finish_search(api.nvim_get_current_buf())
      end
    end
  end
end

-- Runner --

function M.run(search_term, search_args)
  local bufnr = get_buffer()
  local winid = api.nvim_get_current_win()

  local info = reset_search(bufnr, search_term, search_args)

  render_status(bufnr)

  if #search_term == 0 then
    api.nvim_command[[redraw]]
  else
    info.is_searching = true

    local line = -1

    info.job = job:new {
      command = info.cmd,
      args = info.args,
      cwd = info.cwd,
      enable_recording = false,
      interactive = false,
      on_stdout = vim.schedule_wrap(function(_, result_line)
        if is_current_search(info) then
          local result = parse_result(result_line)

          local next_line = push_result(bufnr, line, result)
          local has_next_line = line ~= -1 and line ~= next_line

          line = next_line

          local win_height = api.nvim_win_get_height(winid)
          local res_height = #info.line_array + vim.tbl_count(info.file_table) * 2

          if res_height <= win_height then
            render_result(bufnr, line, result)
          end

          render_status(bufnr)

          if has_next_line then
            highlight_results(bufnr, line - 1)

            if res_height <= win_height + 1 then
              api.nvim_command[[redraw]]
            end
          end
        end
      end),
      on_exit = vim.schedule_wrap(function()
        if is_current_search(info) then
          if info.is_editing then
            finish_search(bufnr)
          end

          api.nvim_command[[redraw]]
        end

        info.is_searching = false
      end),
    }
    info.job:start()
  end
end

-- Navigation --

function M.next_line(step)
  local bufnr = api.nvim_get_current_buf()
  local row = vim.fn.line"."

  if row <= vim.fn.line"$" - 1 then
    local col = tonumber(results_at(bufnr, row)[1].col_number) - 1
    api.nvim_win_set_cursor(api.nvim_get_current_win(), { row + 1, col })
  end
end

function M.prev_line(step)
  local bufnr = api.nvim_get_current_buf()
  local row = vim.fn.line"." - 1

  if row > 0 then
    local results = results_at(bufnr, row - 1)
    local col = tonumber(results[#results].col_number) - 1
    api.nvim_win_set_cursor(api.nvim_get_current_win(), { row, col })
  end
end

function M.first_result()
  local bufnr = api.nvim_get_current_buf()
  local results = results_at(bufnr, 0)

  if #results > 0 then
    local col = tonumber(results[1].col_number) - 1
    api.nvim_win_set_cursor(api.nvim_get_current_win(), { 1, col })
  end
end

function M.last_result()
  local bufnr = api.nvim_get_current_buf()
  local row = vim.fn.line"$"
  local results = results_at(bufnr, row - 1)

  if #results > 0 then
    local col = tonumber(results[#results].col_number) - 1
    api.nvim_win_set_cursor(api.nvim_get_current_win(), { row, col })
  end
end

function M.next_result(step, inclusive)
  local bufnr = api.nvim_get_current_buf()
  local info = M.buffers[bufnr]

  local row = vim.fn.line"."
  local eof = vim.fn.line"$"

  if row <= eof then
    local col = vim.fn.col"." - 1
    local results = results_at(bufnr, row - 1)

    local next_col

    for _ = 1, math.max(step or 1, 1) do
      for _, result in ipairs(results) do
        local curr_col = tonumber(result.col_number) - 1

        if inclusive then
          curr_col = curr_col + #info.search_term
        end

        if (curr_col > col and (next_col == nil or
            (curr_col - col) < (next_col - col))) then
          next_col = curr_col

          if inclusive then
            next_col = next_col - #info.search_term
          end
        end
      end

      if next_col == nil or (not inclusive and next_col == col) then
        row = row + 1

        if row <= eof then
          next_col = tonumber(results_at(bufnr, row - 1)[1].col_number) - 1
        end
      end

      col = next_col
    end

    if row <= eof then
      api.nvim_win_set_cursor(api.nvim_get_current_win(), { row, col })
    end
  end
end

function M.prev_result(step)
  local bufnr = api.nvim_get_current_buf()
  local row = vim.fn.line"."

  if row > 0 then
    local col = vim.fn.col"." - 1
    local results = results_at(bufnr, row - 1)

    local prev_col

    for _ = 1, math.max(step or 1, 1) do
      for _, result in ipairs(results) do
        local curr_col = tonumber(result.col_number) - 1

        if (curr_col < col and (prev_col == nil or
            (col - curr_col) < (col - prev_col))) then
          prev_col = curr_col
        end
      end

      if prev_col == nil or prev_col == col then
        row = row - 1

        if row > 0 then
          results = results_at(bufnr, row - 1)
          prev_col = tonumber(results[#results].col_number) - 1
        end
      end

      col = prev_col
    end

    if row > 0 then
      api.nvim_win_set_cursor(api.nvim_get_current_win(), { row, col })
    end
  end
end

function M.select_next_result(step)
  local bufnr = api.nvim_get_current_buf()
  local info = M.buffers[bufnr]

  api.nvim_command[[normal! v]]

  local mode = vim.fn.mode()

  if mode ~= "v" then
    api.nvim_command[[normal! v]]
  end

  M.next_result(step, true)

  local row = vim.fn.line"."
  local col = vim.fn.col"." + #info.search_term - 1

  if mode == "v" then
    api.nvim_command[[normal! o]]
  end

  api.nvim_win_set_cursor(api.nvim_get_current_win(), { row, col - 1 })
end

function M.select_prev_result(step)
  local bufnr = api.nvim_get_current_buf()
  local info = M.buffers[bufnr]

  api.nvim_command[[normal! v]]

  local mode = vim.fn.mode()

  if mode ~= "v" then
    api.nvim_command[[normal! v]]
  end

  M.prev_result(step, true)

  local row = vim.fn.line"."
  local col = vim.fn.col"." + #info.search_term - 1

  if mode == "v" then
    api.nvim_command[[normal! o]]
    api.nvim_win_set_cursor(api.nvim_get_current_win(), { row, col - 1 })
    api.nvim_command[[normal! o]]
  end
end

return M
