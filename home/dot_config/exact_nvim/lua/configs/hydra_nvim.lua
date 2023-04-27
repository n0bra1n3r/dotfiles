local function debug_hydra()
  local state = {
    [[  [_<Home>_] 󰗼 [_<End>_] ]],
    [[  [_<Home>_]  [_<C-Right>_]  [_<C-Left>_]  [_<C-Up>_]  [_<C-Down>_]  [_<End>_] ]],
    [[  [_<Home>_]  [_<End>_] ]],
  }
  local state_index = 1

  local function dap_repl_open()
    require'dap'.repl.open()
  end

  local function dap_cmd(cmd)
    return function(...)
      require'dap'[cmd](...)
    end
  end

  local hydra
  hydra = require'hydra' {
    name = "Debug",
    hint = [[  [_~_]  [_<Del>_]%{state}]],
    config = {
      color = "pink",
      invoke_on_body = true,
      foreign_keys = "run",
      hint = {
        border = "single",
        funcs = {
          ["state"] = function()
            return state[state_index]
          end,
        },
        position = { "top" },
        type = "window",
      },
      on_enter = function()
        require'dap'.listeners.after.event_continued.debug_hydra = function()
          state_index = 3
          hydra.hint.need_to_update = true
          hydra.hint:update()
        end
        require'dap'.listeners.after.continue.debug_hydra =
          require'dap'.listeners.after.event_continued.debug_hydra
        require'dap'.listeners.after.launch.debug_hydra =
          require'dap'.listeners.after.event_continued.debug_hydra
        require'dap'.listeners.after.event_stopped.debug_hydra = function()
          state_index = 2
          hydra.hint.need_to_update = true
          hydra.hint:update()
        end
        require'dap'.listeners.after.event_terminated.debug_hydra = function()
          state_index = 1
          hydra.layer:exit()
        end
      end,
      on_exit = function()
        require'dap'.listeners.after.event_continued.debug_hydra = nil
        require'dap'.listeners.after.continue.debug_hydra = nil
        require'dap'.listeners.after.launch.debug_hydra = nil
        require'dap'.listeners.after.event_stopped.debug_hydra = nil
        require'dap'.listeners.after.event_terminated.debug_hydra = nil
      end,
    },
    mode = { "n" },
    body = "<leader>d",
    heads = {
      { [[~]], dap_repl_open, { desc = false } },
      { [[<Del>]], dap_cmd[[toggle_breakpoint]], { desc = false } },
      {
        [[<Home>]],
        function()
          if state_index <= 2 then
            dap_cmd[[continue]]()
          else
            dap_cmd[[pause]](1)
          end
        end,
        { desc = false },
      },
      { [[<C-Right>]], dap_cmd[[step_over]], { desc = false } },
      { [[<C-Left>]], dap_cmd[[step_into]], { desc = false } },
      { [[<C-Up>]], dap_cmd[[step_out]], { desc = false } },
      { [[<C-Down>]], dap_cmd[[run_to_cursor]], { desc = false } },
      { [[<End>]], dap_cmd[[terminate]], { exit = true, desc = false } },
    },
  }
end

function plug.config()
  debug_hydra()
end
