local M = {}

local api = vim.api
local job = require "plenary.job"

-- Helper functions --

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

  return "  "..result
end

local function is_search_buf(bufnr)
  return M.buffers ~= nil and M.buffers[bufnr] ~= nil
end

local function is_current_search(bufnr, id)
  local info = M.buffers[bufnr]
  return info ~= nil and info.search_id == id
end

local function get_search_info(bufnr)
  if M.buffers == nil then
    M.buffers = {}
  end

  local info = M.buffers[bufnr]

  if info == nil then
    info = {
      -- Search info
      search_id = 0,
      search_term = nil,
      search_args = nil,
      -- Job info
      args = {},
      cmd = nil,
      cwd = vim.fn.getcwd(),
      job = nil,
      -- Buffer info
      bufnr = bufnr,
      cursor_line = 0,
      line_number_width = 0,
      namespace = string.format("search-%d", bufnr),
      sign_width = 0,
      -- Result info
      change_table = {},
      file_table = {},
      line_array = {},
      result_array = {},
      -- State info
      is_editing = false,
      is_searching = false,
    }

    M.buffers[bufnr] = info
  end

  return info
end

local function get_search_command(search_term, search_args)
  local grep = vim.fn.split(vim.o.grepprg)
  local cmd = grep[1]
  local argList = {select(2, unpack(grep))}

  if search_args ~= nil then
    for arg in string.gmatch(search_args, "%S+") do
      table.insert(argList, arg)
    end
  end

  if search_term ~= nil then
    table.insert(argList, search_term)
  end

  return cmd, argList
end

local function reset_search(bufnr, search_term, search_args)
  local info

  if M.buffers then
    info = M.buffers[bufnr]
    M.buffers[bufnr] = nil
  end

  local new_info = get_search_info(bufnr)

  if info ~= nil then
    api.nvim_command[[echon]]

    if info.job ~= nil and not info.job.is_shutdown then
      info.job:shutdown()
      info.job = nil
    end

    if #info.line_array > 0 then
      for line = 0, api.nvim_buf_line_count(bufnr) - 1 do
        local line_info = info.line_array[line + 1]

        if line_info == nil then
          break
        end

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

    new_info.search_id = info.search_id + 1
    new_info.search_term = search_term or info.search_term
    new_info.search_args = search_args or info.search_args
  else
    new_info.search_term = search_term
    new_info.search_args = search_args
  end

  new_info.cmd, new_info.args = get_search_command(new_info.search_term, new_info.search_args)

  api.nvim_buf_set_option(bufnr, "buftype", "nofile")

  return new_info
end

local function results_at(bufnr, line)
  local info = get_search_info(bufnr)

  if #info.line_array > 0 then
    local line_info = info.line_array[line + 1]
    local line_index = info.file_table[line_info.file_name][line_info.line_number]

    return info.result_array[line_index]
  end

  return {}
end

-- Modes --

local function init_modes()
  if M.modes == nil then
    M.modes = { ' ', ' ' }
    M.mode_id = 0
    M.did_mode_change = false
  end
end

local function reset_modes()
  M.modes = nil
end

local function cycle_mode()
  if M.modes ~= nil then
    M.did_mode_change = true
    M.mode_id = (M.mode_id + 1) % #M.modes

    api.nvim_input("<Enter>")
  end
end

local function get_mode()
  if M.modes ~= nil then
    return M.mode_id, M.modes[M.mode_id + 1]
  end
  return nil, nil
end

local function pop_mode_change()
  if M.modes ~= nil then
    local did_mode_change = M.did_mode_change
    M.did_mode_change = false
    return did_mode_change
  end
  return nil
end

-- Input --

local function clear_input_timer()
  if M.input_timer ~= nil then
    M.input_timer:close()
    M.input_timer = nil
  end
end

local function process_search_input()
  local input = vim.fn.getcmdline()

  if #input > 0 then
    if M.mode_id == 0 then
      M.run(nil, input)
    elseif M.mode_id == 1 then
      M.run(input, nil)
    end
  end

  return input
end

-- Event callbacks --

local function on_cmdline_changed()
  clear_input_timer()

  M.input_timer = vim.loop.new_timer()
  M.input_timer:start(100, 0, vim.schedule_wrap(function()
    clear_input_timer()

    if #process_search_input() == 0 then
      local bufnr = api.nvim_get_current_buf()

      if is_search_buf(bufnr) then
        api.nvim_buf_delete(bufnr, { force = true })
        api.nvim_command[[redraw]]
      end
    end
  end))
end

local function on_cursor_moved(bufnr)
  local info = get_search_info(bufnr)

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

    local scrolloff = api.nvim_get_option("scrolloff")

    if info.cursor_line > line and line <= scrolloff then
      -- TODO: Remove this hack when https://github.com/neovim/neovim/issues/16166 is merged
      vim.fn.winrestview({ topfill = 3 + scrolloff })
    end

    info.cursor_line = line
  end
end

local function on_buf_delete(bufnr)
  if is_search_buf(bufnr) then
    clear_input_timer()
    reset_search(bufnr)
    M.buffers[bufnr] = nil
  end
end

local function on_buf_win_enter(bufnr)
  if is_search_buf(bufnr) then
    local info = get_search_info(bufnr)
    info.is_editing = true

    local winid = api.nvim_get_current_win()

    api.nvim_win_set_option(winid, "number", false)
    api.nvim_win_set_option(winid, "signcolumn", "auto:9")
  end
end

local function on_buf_win_leave(bufnr)
  if is_search_buf(bufnr) then
    local info = get_search_info(bufnr)
    info.is_editing = false

    local winid = api.nvim_get_current_win()

    api.nvim_win_set_option(winid, "number", M.number_enabled)
    api.nvim_win_set_option(winid, "signcolumn", M.signcolumn_option)
  end
end

local function on_buf_write(bufnr)
  local info = get_search_info(bufnr)

  local change_keys = {}

  for key in pairs(info.change_table) do
    table.insert(change_keys, key)
  end

  local file_name, file_open

  for _, key in ipairs(change_keys) do
    local change_info = info.change_table[key]
    local change_line = tonumber(change_info.line_number) - 1

    if change_info.file_name ~= file_name then
      if file_name ~= nil then
        api.nvim_command("write "..file_name)

        if not file_open then
          api.nvim_command("bdelete")
        end
      end

      file_name = change_info.file_name
      file_open = vim.fn.bufnr(file_name) ~= -1

      api.nvim_command("keepjumps edit "..file_name)
    end

    api.nvim_buf_set_lines(
      vim.fn.bufnr(file_name),
      change_line,
      change_line + 1,
      true,
      { change_info.line_text })
  end

  if file_name ~= nil then
    api.nvim_command("write "..file_name)

    if not file_open then
      api.nvim_command("bdelete")
    end

    api.nvim_command("keepjumps buffer "..tostring(bufnr))
  end

  api.nvim_buf_set_option(bufnr, "modified", false)
end

local function on_option_set(bufnr)
  if not is_search_buf(bufnr) then
    local winid = api.nvim_get_current_win()

    M.number_enabled = api.nvim_win_get_option(winid, "number")
    M.signcolumn_option = api.nvim_win_get_option(winid, "signcolumn")
  end
end

local function on_exit(bufnr)
  api.nvim_buf_delete(bufnr, { force = false })
end

-- Initialization --

local function create_buffer_if_needed()
  local bufnr = api.nvim_get_current_buf()

  if not is_search_buf(bufnr) then
    if #api.nvim_buf_get_name(bufnr) > 0 or
        api.nvim_buf_line_count(bufnr) > 0 then
      api.nvim_command[[tabe]]

      return api.nvim_get_current_buf()
    end

    return bufnr
  end
end

local function show_current_result()
  local bufnr = api.nvim_get_current_buf()
  local pos = api.nvim_win_get_cursor(0)
  local result = results_at(bufnr, pos[1] - 1)[1]
  local row = tonumber(result.line_number)
  local col = pos[2]

  api.nvim_command("edit "..result.file_name)
  api.nvim_win_set_cursor(0, { row, col })
end

local function get_buffer()
  local bufnr = create_buffer_if_needed()

  if bufnr ~= nil then
    local winid = api.nvim_get_current_win()

    -- options
    api.nvim_buf_set_name(bufnr, string.format(" Search #%d", vim.tbl_count(M.buffers or {}) + 1))
    api.nvim_buf_set_option(bufnr, "filetype", "search")
    api.nvim_buf_set_option(bufnr, "swapfile", false)
    api.nvim_win_set_option(winid, "number", false)
    api.nvim_win_set_option(winid, "signcolumn", "auto:9")

    -- keybindings
    api.nvim_buf_set_keymap(bufnr, "n", "<Enter>", [[]], {
      callback = show_current_result,
      noremap = true,
    })

    -- autocommands
    local group = api.nvim_create_augroup(string.format("search_%d_on_event", bufnr), { clear = true })
    api.nvim_create_autocmd("BufDelete", {
      group = group,
      buffer = bufnr,
      callback = function()
        api.nvim_del_augroup_by_name(string.format("search_%d_on_event", bufnr))
        on_buf_delete(bufnr)
      end,
    })
    api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      buffer = bufnr,
      callback = function()
        on_buf_win_enter(bufnr)
      end,
    })
    api.nvim_create_autocmd("BufWinLeave", {
      group = group,
      buffer = bufnr,
      callback = function()
        on_buf_win_leave(bufnr)
      end,
    })
    api.nvim_create_autocmd("BufWriteCmd", {
      group = group,
      buffer = bufnr,
      callback = function()
        on_buf_write(bufnr)
      end,
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = group,
      buffer = bufnr,
      callback = function()
        on_cursor_moved(bufnr)
      end,
    })
    api.nvim_create_autocmd("OptionSet", {
      group = group,
      pattern = { "number", "signcolumn" },
      callback = function(args)
        on_option_set(args.buf)
      end,
    })
    api.nvim_create_autocmd("ExitPre", {
      group = group,
      pattern = "*",
      callback = function()
        on_exit(bufnr)
      end,
    })

    return bufnr
  end

  return api.nvim_get_current_buf()
end

-- Search results --

local function render_file_name(bufnr, line, file_name)
  local info = get_search_info(bufnr)

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

    local scrolloff = api.nvim_get_option("scrolloff")

    if line <= scrolloff then
      vim.fn.winrestview({ topfill = 3 + scrolloff })
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
  local info = get_search_info(bufnr)

  local group = get_sign_group(info.namespace, file_name, line_number)
  local label = get_line_number_label(line_number, math.max(0, info.line_number_width - #line_number))

  if #line_number <= info.line_number_width then
    render_line_number_sign(bufnr, line, group, label)
  else
    for i, line_info in ipairs(info.line_array) do
      local prev_line = i - 1
      local prev_group = get_sign_group(info.namespace, line_info.file_name, line_info.line_number)
      local prev_label = get_line_number_label(line_info.line_number, #line_number - #line_info.line_number)
      render_line_number_sign(bufnr, prev_line, prev_group, prev_label)
    end

    info.line_number_width = #line_number
    info.sign_width = render_line_number_sign(bufnr, line, group, label)
  end
end

local function render_result(bufnr, line, result)
  local info = get_search_info(bufnr)

  if result.is_first_col then
    render_line_text(bufnr, line, result.line_text)
    render_line_number(bufnr, line, result.file_name, result.line_number, info)
  end

  local namespace = api.nvim_create_namespace(info.namespace.."-results")

  local col_start = tonumber(result.col_number) - 1
  local col_end = col_start + #info.search_term

  api.nvim_buf_add_highlight(
    bufnr,
    namespace,
    "IncSearch",
    line,
    col_start,
    col_end)

  if result.is_first_line then
    render_file_name(bufnr, line, result.file_name)
  end
end

local function render_stats(bufnr)
  local info = get_search_info(bufnr)
  local line_info = info.line_array[info.cursor_line + 1]

  local namespace = api.nvim_create_namespace(info.namespace.."-"..line_info.file_name)
  local header = api.nvim_buf_get_extmark_by_id(bufnr, namespace, 1, { details = true })[3]

  local total_file_count = vim.tbl_count(info.file_table)
  local total_line_count = #info.line_array

  local search_stats

  if info.is_searching then 
    search_stats = {{
      string.format(" Found <%s> in %d lines in %d files... ", info.search_term, total_line_count, total_file_count),
      "Substitute",
    }}
  else
    search_stats = {{
      string.format(" Found <%s> in %d lines in %d files. ", info.search_term, total_line_count, total_file_count),
      "IncSearch",
    }}
  end

  header.id = 1

  if #header.virt_lines == 2 then
    table.insert(header.virt_lines, 1, search_stats)
  else
    header.virt_lines[1] = search_stats
  end

  api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, header)
end

-- Text replacement --

local function save_modification(bufnr, line)
  local info = get_search_info(bufnr)
  local text = api.nvim_buf_get_lines(bufnr, line, line + 1, {})[1]
  local result = results_at(bufnr, line)[1]

  if text == result.line_text then
    info.change_table[line + 1] = nil
  else
    info.change_table[line + 1] = {
      file_name = result.file_name,
      line_number = result.line_number,
      line_text = text,
    }
  end
end

local function watch_modifications(bufnr)
  local info = get_search_info(bufnr)

  api.nvim_buf_attach(bufnr, false, {
	  on_bytes = vim.schedule_wrap(function(
        _, bufnr, _,
        first_line, first_line_col, buffer_offset,
        line_offset, last_line_col, change_len,
        new_line_offset, new_last_line_col, new_change_len)
      if not is_current_search(bufnr, info.search_id) then
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

-- API --

local function clear_buffer_undo(bufnr)
  local undo_levels = api.nvim_buf_get_option(bufnr, "undolevels")
  api.nvim_buf_set_option(bufnr, "undolevels", -1)
  api.nvim_command[[exec "normal! a \<BS>\<Esc>"]]
  api.nvim_buf_set_option(bufnr, "undolevels", undo_levels)
end

local function finish_search(bufnr)
  local info = get_search_info(bufnr)

  local start_line = api.nvim_buf_line_count(bufnr)
  local end_line = #info.result_array - 1

  for line = start_line, end_line do
    for _, result in ipairs(info.result_array[line + 1]) do
      render_result(bufnr, line, result)
    end
  end

  render_stats(bufnr)

  clear_buffer_undo(bufnr)

  api.nvim_buf_set_option(bufnr, "modified", false)
  api.nvim_buf_set_option(bufnr, "buftype", "acwrite")

  local first_result = info.result_array[1][1]
  local first_col = tonumber(first_result.col_number) - 1

  local winid = api.nvim_get_current_win()

  api.nvim_win_set_cursor(winid, { 1, first_col })

  local namespace = api.nvim_create_namespace(info.namespace.."-results")

  api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  vim.fn.setreg("/", info.search_term, vim.fn.getregtype("/"))

  if M.hlsearch_enabled then
    api.nvim_set_option("hlsearch", true)
  end

  clear_input_timer()
  process_search_input()

  watch_modifications(bufnr)
end

local function enable_live_search()
  local group = api.nvim_create_augroup("search_on_cmdline_changed", { clear = true })
  api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    pattern = "*",
    callback = on_cmdline_changed,
  })

  init_modes()

  vim.fn.inputsave()
end

local function disable_live_search()
  vim.fn.inputrestore()

  reset_modes()

  api.nvim_del_augroup_by_name("search_on_cmdline_changed")
end

local function search_entry_add_mapping(lhs, callback, expr)
  local mapping = vim.fn.maparg(lhs, "c", 0, 1)

  mapping.lhs = lhs

  if mapping.rhs ~= nil then
    api.nvim_del_keymap("c", lhs)
  end

  api.nvim_set_keymap("c", lhs, [[]], { callback = callback, noremap = true, expr = expr })

  return mapping
end

local function search_entry_del_mapping(mapping)
  api.nvim_del_keymap("c", mapping.lhs)

  if mapping.rhs ~= nil then
    api.nvim_set_keymap("c", mapping.lhs, mapping.rhs, {
      expr = mapping.expr,
      noremap = mapping.noremap,
      nowait = mapping.nowait,
      silent = mapping.silent,
      script = mapping.script,
    })
  end
end

local function dismiss_if_needed()
  if #vim.fn.getcmdline() == 0 then
    api.nvim_input("<Esc>")
  end
  return api.nvim_replace_termcodes("<Backspace>", true, true, true)
end

local function get_last_search(search_term, search_args)
  local bufnr = api.nvim_get_current_buf()
  local info = M.buffers and M.buffers[bufnr]

  if info ~= nil then
    return info.search_term or search_term, info.search_args or search_args
  end
  return search_term, search_args
end

function M.prompt(search_args, search_term)
  local winid = api.nvim_get_current_win()

  -- save options so we can restore them
  M.hlsearch_enabled = api.nvim_get_option("hlsearch")
  M.number_enabled = api.nvim_win_get_option(winid, "number")
  M.signcolumn_option = api.nvim_win_get_option(winid, "signcolumn")

  api.nvim_set_option("hlsearch", false)

  local tab_mapping = search_entry_add_mapping("<Tab>", cycle_mode)
  local bs_mapping = search_entry_add_mapping("<Backspace>", dismiss_if_needed, true)

  enable_live_search()

  local search_term, search_args = get_last_search(search_term, search_args)

  local search_input = search_term

  while true do
    local mode_id, mode_icon = get_mode()

    search_input = vim.fn.input {
      default = search_input,
      prompt = string.format(" %s ", mode_icon),
    }

    if not pop_mode_change() then
      break
    end

    mode_id, mode_icon = get_mode()

    if mode_id == 0 then
      search_input, search_args = get_last_search(search_term, search_args)
    else
      search_term, search_input = get_last_search(search_term, search_args)
    end
  end

  disable_live_search()

  search_entry_del_mapping(bs_mapping)
  search_entry_del_mapping(tab_mapping)

  local bufnr = api.nvim_get_current_buf()

  if is_search_buf(bufnr) then
    if #search_input == 0 then
      api.nvim_buf_delete(bufnr, { force = true })
      api.nvim_set_option("hlsearch", M.hlsearch_enabled)
      api.nvim_command[[redraw]]
    else
      local info = get_search_info(bufnr)

      if not info.is_searching then
        finish_search(bufnr)
      end
    end
  end
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

  local parsed_result = {}

  for s, i in pairs(part_index) do
    local key = ({
      f = "file_name",
      l = "line_number",
      c = "col_number",
      m = "line_text",
    })[s]

    parsed_result[key] = part_array[i + 1]
  end

  return parsed_result
end

local function push_result(bufnr, line, result)
  local info = get_search_info(bufnr)

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

function M.run(search_args, search_term)
  local bufnr = get_buffer()
  local info = reset_search(bufnr, search_term, search_args)

  if info.search_term == nil then
    return
  end

  local winid = api.nvim_get_current_win()

  info.is_searching = true

  local line = -1
  local redraw_threshold = -1

  info.job = job:new {
    command = info.cmd,
    args = info.args,
    cwd = info.cwd,
    enable_recording = false,
    interactive = false,
    on_stdout = vim.schedule_wrap(function(_, result_line)
      if is_current_search(bufnr, info.search_id) then
        local result = parse_result(result_line)

        local next_line = push_result(bufnr, line, result)
        local has_next_line = line ~= -1 and line ~= next_line

        line = next_line

        local win_height = api.nvim_win_get_height(winid)
        local res_height = #info.line_array + vim.tbl_count(info.file_table) * 2

        if res_height <= win_height then
          render_result(bufnr, line, result)
        end

        if line > redraw_threshold then
          render_stats(bufnr)

          api.nvim_command[[redraw]]

          redraw_threshold = line + line / 3
        end
      end
    end),
    on_exit = vim.schedule_wrap(function()
      info.is_searching = false

      if is_current_search(bufnr, info.search_id) then
        if info.is_editing then
          finish_search(bufnr)
        else
          render_stats(bufnr)
        end

        api.nvim_command[[redraw]]
      end
    end),
  }
  info.job:start()
end

return M
