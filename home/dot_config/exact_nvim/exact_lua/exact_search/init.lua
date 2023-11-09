local M = {}

local search_icon = '󱉶'
local replace_icon = '󰛔'
local search_filetype = "search"
local search_namespace = "Search"
local search_scrolloff = 3
local search_statuscol = "%!v:lua.search_statuscol_expr()"

local augroup_live_search = "search_live_search"
local augroup_open_search_buffer = "search_open_search_buffer"

local function get_search_icon_color()
  local _, color = require'nvim-web-devicons'.get_icon_color_by_filetype("help")
  return color
end

local function get_search_icon_cterm_color()
  local _, color = require'nvim-web-devicons'.get_icon_cterm_color_by_filetype("help")
  return color
end

require'nvim-web-devicons'.set_icon {
  [search_filetype] = {
    icon = search_icon,
    color = get_search_icon_color(),
    cterm_color = get_search_icon_cterm_color(),
    name = search_namespace,
  },
}

local function get_search_icon()
  local icon, _ = require'nvim-web-devicons'.get_icon("search")
  return icon
end

local function get_search_match_namespace()
  return vim.api.nvim_create_namespace(search_namespace.."-match")
end

local function get_search_file_namespace(name)
  local postfix = name and ("-file-"..name) or ""
  return vim.api.nvim_create_namespace(search_namespace..postfix)
end

local function construct_search_command(search_term, search_args)
  local grep = vim.fn.split(vim.o.grepprg)
  local cmd = grep[1]
  local argList = {select(2, unpack(grep))}

  if search_args then
    for arg in search_args:gmatch("%S+") do
      table.insert(argList, arg)
    end
  end

  if search_term then
    table.insert(argList, search_term)
  end

  return cmd, argList
end

local function get_current_search_buffer()
  return M.info and M.info.bufnr
end

local function get_is_search_buffer_open()
  local bufnr = get_current_search_buffer()
  return bufnr and #vim.fn.win_findbuf(bufnr) > 0
end

local function get_is_in_search_buffer()
  return get_current_search_buffer() == vim.api.nvim_get_current_buf()
end

local function get_search_info()
  if not M.info and vim.bo.filetype == search_filetype then
    M.info = {
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
      bufnr = vim.api.nvim_get_current_buf(),
      cursor_line = 0,
      max_line_number = 0,
      -- Result info
      change_table = {},
      file_table = {},
      line_array = {},
      result_array = {},
      -- State info
      is_editing = false,
      is_searching = false,
    }
  end
  return M.info
end

local function get_search_results_at(line)
  local info = get_search_info()
  if #info.line_array > 0 then
    local line_info = info.line_array[line + 1]
    local line_index = info.file_table[line_info.file_name][line_info.line_number]
    return info.result_array[line_index]
  end
  return {}
end

local function replace_search_results_at(line, text)
  local info = get_search_info()
  if #info.line_array > 0 then
    local line_info = info.line_array[line + 1]
    local line_index = info.file_table[line_info.file_name][line_info.line_number]
    for _, result in ipairs(info.result_array[line_index]) do
      result.line_text = text
    end
  end
end

local function get_is_current_search(id)
  return M.info and M.info.search_id == id
end

local function save_opt(store, name)
  if not M.saved_opts then
    M.saved_opts = {}
  end
  M.saved_opts[name] = store[name]
end

local function load_opt(store, name)
  if M.saved_opts then
    store[name] = M.saved_opts[name]
  end
end

local function set_search_window_options()
  save_opt(vim.wo, "colorcolumn")
  save_opt(vim.wo, "scrolloff")
  save_opt(vim.wo, "statuscolumn")

  vim.wo.colorcolumn = nil
  vim.wo.scrolloff = search_scrolloff
  vim.wo.statuscolumn = search_statuscol
end

local function unset_search_window_options()
  load_opt(vim.wo, "colorcolumn")
  load_opt(vim.wo, "scrolloff")
  load_opt(vim.wo, "statuscolumn")
end

local function show_current_search_result(cmd)
  local pos = vim.api.nvim_win_get_cursor(0)
  local result = get_search_results_at(pos[1] - 1)[1]
  local row = tonumber(result.line_number)
  local col = pos[2]

  vim.cmd[[tabclose]]
  vim.cmd(("%s %s"):format(cmd, result.file_name))
  vim.api.nvim_win_set_cursor(0, { row, col })
end

local function maybe_create_search_buffer()
  if not get_is_in_search_buffer() then
    local bufnr = get_current_search_buffer()
    if bufnr then
      for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
        local tabpage = vim.api.nvim_win_get_tabpage(winid)
        vim.api.nvim_set_current_tabpage(tabpage)
        vim.api.nvim_set_current_win(winid)
        break
      end
      vim.cmd.tabedit("#"..bufnr)
      return nil
    end

    vim.cmd[[tabnew]]
    return vim.api.nvim_get_current_buf()
  end
end

local function clear_search_buffer_undo_tree()
  local undo_levels = vim.bo.undolevels
  vim.bo.undolevels = -1
  vim.cmd[[exec "normal! a‎\<BS>\<Esc>"]]
  vim.bo.undolevels = undo_levels
  vim.bo.modified = false
end

local function initialize_search(search_term, search_args)
  local info = M.info
  M.info = nil

  local new_info = get_search_info()

  if info then
    vim.cmd[[echon]]

    if info.job and not info.job.is_shutdown then
      info.job:shutdown()
      info.job = nil
    end

    new_info.search_id = info.search_id + 1
    new_info.search_term = search_term or info.search_term
    new_info.search_args = search_args or info.search_args
  else
    new_info.search_term = search_term
    new_info.search_args = search_args
  end

  new_info.cmd, new_info.args = construct_search_command(
    new_info.search_term,
    new_info.search_args)

  vim.bo.buftype = 'nowrite'

  set_search_window_options()

  vim.api.nvim_buf_clear_namespace(0, -1, 0, -1)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, { '', '' })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  return new_info
end

local function render_line_text(line, line_text)
  local cursor = vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_buf_set_lines(
    0,
    line,
    line > 0 and line or line + 1,
    true,
    { line_text })

  if vim.deep_equal(cursor, { 1, 0 }) then
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end
end

local function render_file_name(line, file_name)
  local namespace = get_search_file_namespace(file_name)

  vim.api.nvim_buf_clear_namespace(0, get_search_file_namespace(), 0, -1)
  vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)

  if line >= 0 then
    local name = vim.fn.fnamemodify(file_name, ':t')
    local ext = vim.fn.fnamemodify(name, ':e')
    local icon, hl = require'nvim-web-devicons'.get_icon(name, ext)
    vim.api.nvim_buf_set_extmark(0, namespace, line, 0, {
      id = line + 1,
      virt_lines = {
        {{ '' }},
        {
          { ' ' },
          {
            '┌',
            'LineNr',
          },
          { ' ' },
          {
            icon,
            hl,
          },
          { ' ' },
          {
            ('%s:'):format(file_name),
            'Directory',
          }
        },
      },
      virt_lines_above = true,
      virt_lines_leftcol = true,
    })

    if line <= search_scrolloff then
      vim.fn.winrestview{ topfill = 3 + search_scrolloff }
    end
  end
end

local function enable_progress_timer()
  if not M.progress then
    M.progress = {
      icons = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      index = 1,
    }
  end

  if not M.progress.timer then
    M.progress.timer = vim.loop.new_timer()
    M.progress.timer:start(0, 100, function()
      M.progress.index = M.progress.index % #M.progress.icons + 1
    end)
  end
end

local function get_progress_icon()
  return M.progress.timer and M.progress.icons[M.progress.index]
end

local function clear_progress_timer()
  if M.progress and M.progress.timer then
    M.progress.index = 1
    M.progress.timer:close()
    M.progress.timer = nil
  end
end

local function render_statistics(is_modified)
  local info = get_search_info()
  if #info.line_array > 0 then
    local file_name = info.line_array[1].file_name
    local namespace = get_search_file_namespace(file_name)
    local extmarks = vim.api.nvim_buf_get_extmarks(
      0,
      namespace,
      0,
      -1,
      { details = true })
    if #extmarks > 0 then
      local progress_icon = get_progress_icon()
      local finished_icon = is_modified and replace_icon or get_search_icon()
      local finished_hl = is_modified and 'Substitute' or 'IncSearch'

      local change_count = 0
      local change_files = {}
      for _, change in pairs(info.change_table) do
        change_count = change_count + 1
        change_files[change.file_name] = 1
      end

      local replace_msg = is_modified and (" Replacing %s lines in %s files.")
        :format(change_count, vim.tbl_count(change_files)) or ''

      local stats = {
        { ' ' },
        {
          (" %s  Matched %d lines in %d files%s "):format(
            progress_icon or finished_icon,
            #info.line_array,
            vim.tbl_count(info.file_table),
            progress_icon and "..." or "."..replace_msg),
            progress_icon and 'CurSearch' or finished_hl,
        },
      }

      vim.api.nvim_buf_clear_namespace(0, get_search_file_namespace(), 0, -1)
      vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)

      local line = extmarks[1][2]
      local col = extmarks[1][3]

      local extmark = extmarks[1][4]
      extmark.ns_id = nil
      extmark.id = extmarks[1][1]

      if #extmark.virt_lines[1] == 1 and
          #extmark.virt_lines[1][1] == 1 and
          #extmark.virt_lines[1][1][1] == 0 then
        table.insert(extmark.virt_lines, 1, stats)
      else
        extmark.virt_lines[1] = stats
      end

      vim.api.nvim_buf_set_extmark(0, namespace, line, col, extmark)
    end
  else
    local namespace = get_search_file_namespace()

    vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)

    local progress_icon = get_progress_icon()

    vim.api.nvim_buf_set_extmark(0, namespace, 0, 0, {
      id = 1,
      virt_lines = {{
        { ' ' },
        {
          (" %s  No matches found%s "):format(
            progress_icon or get_search_icon(),
            progress_icon and "..." or "."),
          'Search',
        },
      }},
      virt_lines_above = true,
      virt_lines_leftcol = true,
    })

    vim.fn.winrestview{ topfill = 3 + search_scrolloff }
  end
end

local function render_result(line, result)
  if result.is_first_col then
    render_line_text(line, result.line_text)
  end

  vim.o.hlsearch = false

  local info = get_search_info()
  local namespace = get_search_match_namespace()
  local col_start = tonumber(result.col_number) - 1
  local col_end = col_start + #info.search_term

  vim.api.nvim_buf_add_highlight(
    0,
    namespace,
    "IncSearch",
    line,
    col_start,
    col_end)

  if result.is_first_line then
    render_file_name(line, result.file_name)
  end
end

local function save_modification(line)
  local info = get_search_info()
  local text = vim.api.nvim_buf_get_lines(0, line, line + 1, {})[1]
  local result = get_search_results_at(line)[1]

  if text == result.line_text then
    info.change_table[line + 1] = nil
  else
    info.change_table[line + 1] = {
      file_name = result.file_name,
      line_number = result.line_number,
      line_text = text,
    }
  end

  render_statistics(vim.tbl_count(info.change_table) > 0)
end

local function watch_modifications()
  local info = get_search_info()
  vim.api.nvim_buf_attach(0, false, {
	  on_bytes = vim.schedule_wrap(function(
        _, _, _,
        first_line, first_line_col, _,
        line_offset, last_line_col, _,
        new_line_offset, _, _)
      if not get_is_current_search(info.search_id) then
        return true
      end

      if line_offset > new_line_offset then
        -- lines were removed

        local last_line = first_line + line_offset - 1

        if first_line_col ~= 0 or last_line_col ~= 0 then
          save_modification(first_line)
        end

        for _ = first_line + 1, last_line + 1 do
          local line_info = info.line_array[first_line + 1]

          table.remove(info.line_array, first_line + 1)

          if line_info.file_name ~= nil then
            local line_table = info.file_table[line_info.file_name]
            line_table[line_info.line_number] = nil
            if vim.tbl_count(line_table) == 0 then
              render_file_name(-1, line_info.file_name)
              render_statistics()
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

              local min_index = index
              for _, i in pairs(line_table) do
                min_index = math.min(min_index, i)
              end

              if index == min_index then
                render_file_name(line, result.file_name)
                render_statistics()
              end

              if index <= last_index then
                table.insert(info.line_array, line + 1, {
                  file_name = result.file_name,
                  line_number = result.line_number,
                })

                local line_text = vim.api.nvim_buf_get_lines(
                  0,
                  line,
                  line + 1,
                  true)[1]
                if line_text ~= result.line_text then
                  save_modification(line)
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

        save_modification(first_line)
      end
    end),
  })
end

local function finalize_search()
  local info = get_search_info()

  if #info.line_array == 0 then
    vim.api.nvim_buf_delete(0, { force = true })
    vim.cmd[[redraw]]
    return
  end

  local start_line = vim.api.nvim_buf_line_count(0) - 1
  local end_line = #info.result_array - 1

  for line = start_line, end_line do
    for _, result in ipairs(info.result_array[line + 1]) do
      render_result(line, result)
    end
  end

  clear_search_buffer_undo_tree()

  vim.bo.buftype = 'acwrite'

  local namespace = get_search_match_namespace()
  vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)

  vim.fn.setreg('/', info.search_term, vim.fn.getregtype('/'))
  vim.o.hlsearch = true

  set_search_window_options()

  watch_modifications()
end

local function on_buf_delete()
  M.info = nil
end

local function on_cmdline_enter()
  local info = get_search_info()
  info.is_editing = true
end

local function on_cmdline_leave()
  local info = get_search_info()
  info.is_editing = false
end

local function on_cursor_moved()
  local info = get_search_info()
  local line = vim.fn.line"." - 1
  if info.cursor_line ~= line then
    if info.cursor_line > line and line <= search_scrolloff then
      -- TODO: Remove this hack when https://github.com/neovim/neovim/issues/16166 is merged
      vim.fn.winrestview{ topfill = 3 + search_scrolloff }
    end
    info.cursor_line = line
  end
end

local function on_buf_write_cmd()
  local info = get_search_info()

  local change_keys = {}
  for key in pairs(info.change_table) do
    table.insert(change_keys, key)
  end

  local file_name, is_file_open
  for _, key in ipairs(change_keys) do
    local change_info = info.change_table[key]
    local change_line = tonumber(change_info.line_number) - 1

    if change_info.file_name ~= file_name then
      if file_name ~= nil then
        vim.cmd.write(file_name)
        if not is_file_open then
          vim.cmd[[bwipe]]
        end
      end

      file_name = change_info.file_name
      is_file_open = vim.fn.bufnr(file_name) ~= -1

      vim.cmd('keepjumps edit '..file_name)
    end

    replace_search_results_at(key - 1, change_info.line_text)

    vim.api.nvim_buf_set_lines(
      vim.fn.bufnr(file_name),
      change_line,
      change_line + 1,
      true,
      { change_info.line_text })
  end

  if file_name ~= nil then
    vim.cmd.write(file_name)
    if not is_file_open then
      vim.cmd[[bwipe]]
    end

    vim.cmd('keepjumps buffer '..info.bufnr)
  end

  vim.bo.modified = false
  info.change_table = {}

  render_statistics(false)
end

local function on_exit()
  local bufnr = get_current_search_buffer()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = false })
  end
end

local function open_search_buffer()
  local bufnr = maybe_create_search_buffer()
  if bufnr then
    -- options
    vim.api.nvim_buf_set_name(bufnr, search_namespace)
    vim.bo.buftype = "nowrite"
    vim.bo.filetype = search_filetype
    vim.bo.swapfile = false

    -- keybindings
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<Enter>", [[]], {
      callback = function()
        show_current_search_result("edit")
      end,
      noremap = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<M-\\>", [[]], {
      callback = function()
        show_current_search_result("vsplit")
      end,
      noremap = true,
    })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<M-->", [[]], {
      callback = function()
        show_current_search_result("split")
      end,
      noremap = true,
    })

    -- autocommands
    local group = vim.api.nvim_create_augroup(augroup_open_search_buffer,
      { clear = true })

    vim.api.nvim_create_autocmd("BufDelete", {
      group = group,
      buffer = bufnr,
      callback = function()
        vim.api.nvim_del_augroup_by_name(augroup_open_search_buffer)
        on_buf_delete()
      end,
    })
    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      buffer = bufnr,
      callback = set_search_window_options,
    })
    vim.api.nvim_create_autocmd('BufLeave', {
      group = group,
      buffer = bufnr,
      callback = unset_search_window_options,
    })
    vim.api.nvim_create_autocmd('CmdlineLeave', {
      group = group,
      buffer = bufnr,
      callback = on_cmdline_enter,
    })
    vim.api.nvim_create_autocmd('CmdlineEnter', {
      group = group,
      buffer = bufnr,
      callback = on_cmdline_leave,
    })
    vim.api.nvim_create_autocmd('BufWriteCmd', {
      group = group,
      buffer = bufnr,
      callback = on_buf_write_cmd,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = group,
      buffer = bufnr,
      callback = on_cursor_moved,
    })
    vim.api.nvim_create_autocmd("ExitPre", {
      group = group,
      callback = on_exit,
    })
  end
end

local function parse_result(result_line)
  if not result_line then
    return nil
  end

  local format = vim.o.grepformat
  local part_index = {}
  local index = 0
  local pattern = string.gsub(format, "%%(%a)", function(s)
    -- convert grepformat format token to regex
    part_index[s] = index
    index = index + 1
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

local function push_result(line, result)
  local info = get_search_info()
  info.max_line_number = math.max(info.max_line_number, result.line_number)

  result.is_first_line = false
  result.is_first_col = false

  local file_info = info.file_table[result.file_name]
  if not file_info then
    line = line + 1

    info.file_table[result.file_name] = {
      [result.line_number] = line + 1,
    }

    result.is_first_line = true
    result.is_first_col = true
  elseif not file_info[result.line_number] then
    line = line + 1

    file_info[result.line_number] = line + 1

    result.is_first_col = true
  end

  local results = info.result_array[line + 1]
  if not results then
    info.result_array[line + 1] = { result }
  else
    table.insert(results, result)
  end

  info.line_array[line + 1] = {
    file_name = result.file_name,
    is_first_line = result.is_first_line,
    line_number = result.line_number,
  }

  return line
end

function M.run(search_args, search_term)
  open_search_buffer()

  local info = initialize_search(search_term, search_args)
  if not info.search_term then
    return
  end

  info.is_searching = true

  enable_progress_timer()
  render_statistics()

  local line = -1
  local redraw_threshold = -1

  info.job = require'plenary.job':new {
    command = info.cmd,
    args = info.args,
    cwd = info.cwd,
    enable_recording = false,
    interactive = false,
    on_stdout = vim.schedule_wrap(function(_, result_line)
      if get_is_current_search(info.search_id) then
        local result = parse_result(result_line)
        if result then
          local next_line = push_result(line, result)

          line = next_line

          local win_height = vim.api.nvim_win_get_height(0)
          local res_height = #info.line_array + vim.tbl_count(info.file_table) * 2

          if res_height <= win_height then
            render_result(line, result)
          end

          render_statistics()

          if line > redraw_threshold then
            vim.cmd[[redraw]]

            redraw_threshold = line + line / 3
          end
        end
      end
    end),
    on_exit = vim.schedule_wrap(function()
      info.is_searching = false

      if get_is_current_search(info.search_id) then
        if info.is_editing then
          finalize_search()
        end

        clear_progress_timer()
        render_statistics()

        vim.cmd[[redraw]]
      end
    end),
  }

  info.job:start()
end

local function process_search_input()
  local input = vim.fn.getcmdline()
  if #input > 0 then
    M.run(nil, input)
  end

  return input
end

local function clear_input_timer()
  if M.input_timer then
    M.input_timer:close()
    M.input_timer = nil
  end
end

local function on_cmdline_changed()
  clear_input_timer()

  local delay_factor = math.max(6 - #vim.fn.getcmdline(), 1)

  M.input_timer = vim.loop.new_timer()
  M.input_timer:start(200 * delay_factor, 0, vim.schedule_wrap(function()
    clear_input_timer()
    if #process_search_input() == 0 then
      if get_is_in_search_buffer() then
        vim.api.nvim_buf_delete(0, { force = true })
        vim.cmd[[redraw]]
      end
    end
  end))
end

local function enable_live_search()
  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = vim.api.nvim_create_augroup(augroup_live_search, { clear = true }),
    callback = on_cmdline_changed,
  })
  vim.fn.inputsave()
  vim.cmd.echohl("Constant")
end

local function disable_live_search()
  clear_input_timer()
  vim.cmd.echohl("None")
  vim.fn.inputrestore()
  vim.api.nvim_del_augroup_by_name(augroup_live_search)
end

local function get_last_search(search_term, search_args)
  if M.info then
    return M.info.search_term or search_term, M.info.search_args or search_args
  end
  return search_term, search_args
end

local function dismiss_if_needed()
  if #vim.fn.getcmdline() == 0 then
    vim.api.nvim_input[[<Esc>]]
  end
  return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
end

local function set_search_prompt_mapping(lhs, callback, expr)
  local mapping = vim.fn.maparg(lhs, "c", 0, 1)
  mapping.lhs = lhs

  if mapping.rhs ~= nil then
    vim.api.nvim_del_keymap("c", lhs)
  end

  vim.api.nvim_set_keymap("c", lhs, [[]],
    { callback = callback, noremap = true, expr = expr })

  return mapping
end

local function unset_search_prompt_mapping(mapping)
  vim.api.nvim_del_keymap("c", mapping.lhs)

  if mapping.rhs ~= nil then
    vim.api.nvim_set_keymap("c", mapping.lhs, mapping.rhs, {
      expr = mapping.expr,
      noremap = mapping.noremap,
      nowait = mapping.nowait,
      silent = mapping.silent,
      script = mapping.script,
    })
  end
end

function M.prompt(search_args, search_term)
  local bs_mapping = set_search_prompt_mapping("<BS>", dismiss_if_needed, true)

  enable_live_search()

  if get_is_search_buffer_open() then
    search_term, search_args = get_last_search(search_term, search_args)
  end

  search_term = vim.fn.input {
    default = search_term,
    highlight = function(input)
      return {{ 0, #input, "CurSearch" }}
    end,
    prompt = ("  %s  "):format(get_search_icon()),
  }

  disable_live_search()

  unset_search_prompt_mapping(bs_mapping)

  if get_is_in_search_buffer() then
    if #search_term == 0 then
      vim.api.nvim_buf_delete(0, { force = true })
      vim.cmd[[redraw]]
    else
      local info = get_search_info()

      if not info.is_searching then
        finalize_search()
      end

      if vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 1, 0 }) then
        local first_result = info.result_array[1][1]
        local first_col = tonumber(first_result.col_number) - 1

        vim.api.nvim_win_set_cursor(0, { 1, first_col })
      end
    end
  end
end

function _G.search_statuscol_expr()
  local line = vim.v.lnum
  if line then
    local info = get_search_info()
    if #info.line_array > 0 then
      local line_info = info.line_array[line]
      if line_info then
        local lnum = line_info.line_number
        local lmax = info.max_line_number

        if vim.v.virtnum == 0 then
          local padding = (' '):rep(#tostring(lmax) - #tostring(lnum))
          local has_lhl = vim.wo.cursorlineopt == 'number'
            or vim.wo.cursorlineopt == 'both'
          local lhl = has_lhl and vim.fn.line('.') == line
            and 'CursorLineNr'
            or 'LineNr'
          local next_line_info = info.line_array[line + 1]
          local is_last_line = not next_line_info or next_line_info.is_first_line
          return (' %%#LineNr#%s%s%%#%s#%d '):format(
            is_last_line and '└' or '│',
            padding,
            lhl,
            line_info.line_number)
        end
      end
    end
  end
  return [[]]
end

return M
