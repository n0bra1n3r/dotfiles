local function debug_hydra()
  local state = {
    [[  [_<Home>_] 󰗼 [_<End>_] ]],
    [[  [_<Home>_]  [_<F9>_]  [_<F10>_]  [_<F11>_]  [_<F12>_]  [_<End>_] ]],
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
    hint = [[  [_~_]  [_<Insert>_]%{state}]],
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
          require'dap'.listeners.after.event_continued.debug_hydra = nil
          require'dap'.listeners.after.continue.debug_hydra = nil
          require'dap'.listeners.after.launch.debug_hydra = nil
          require'dap'.listeners.after.event_stopped.debug_hydra = nil
          require'dap'.listeners.after.event_terminated.debug_hydra = nil
          require'dap'.listeners.after.disconnect.debug_hydra = nil
          require'dap'.listeners.after.terminate.debug_hydra = nil
        end
        require'dap'.listeners.after.disconnect.debug_hydra =
          require'dap'.listeners.after.event_terminated.debug_hydra
        require'dap'.listeners.after.terminate.debug_hydra =
          require'dap'.listeners.after.event_terminated.debug_hydra
      end,
    },
    mode = { "n" },
    body = "<leader>d",
    heads = {
      { [[~]], dap_repl_open, { desc = false } },
      { [[<Insert>]], dap_cmd[[toggle_breakpoint]], { desc = false } },
      {
        [[<Home>]],
        function()
          if state_index == 3 then
            dap_cmd[[pause]](1)
          else
            dap_cmd[[continue]]()
          end
        end,
        { desc = false },
      },
      { [[<F9>]], dap_cmd[[step_over]], { desc = false } },
      { [[<F10>]], dap_cmd[[step_into]], { desc = false } },
      { [[<F11>]], dap_cmd[[step_out]], { desc = false } },
      { [[<F12>]], dap_cmd[[run_to_cursor]], { desc = false } },
      { [[<End>]], dap_cmd[[terminate]], { exit = true, desc = false } },
    },
  }

  vim.api.nvim_set_hl(0, "HydraRed", { link = "Error" })
  vim.api.nvim_set_hl(0, "HydraBlue", { link = "Function" })
  vim.api.nvim_set_hl(0, "HydraAmaranth", { link = "Constant" })
  vim.api.nvim_set_hl(0, "HydraTeal", { link = "Operator" })
  vim.api.nvim_set_hl(0, "HydraPink", { link = "Identifier" })
end

function plug.config()
  debug_hydra()
end
