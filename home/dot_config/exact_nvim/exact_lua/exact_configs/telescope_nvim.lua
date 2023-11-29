-- vim: fcl=all fdm=marker fdl=0 fen

--{{{ Helpers
local function make_git_branch_action(opts)
  return function(prompt_bufnr)
    local cwd = require'telescope.actions.state'.get_current_picker(prompt_bufnr).cwd
    local selection = require'telescope.actions.state'.get_selected_entry()
    if selection == nil then
      return
    end

    require'telescope.actions'.close(prompt_bufnr)

    local cmd = opts.command(selection.value)

    fn.exec_task(
      cmd[1],
      vim.list_slice(cmd, 2),
      opts.action_name,
      {
        EDITOR=vim.fn.join {
          'nvim',
          '--clean',
          '--headless',
          '--server',
          '"'..vim.v.servername..'"',
          '--remote-tab',
        },
      },
      cwd)
  end
end
--}}}

return {
  config = function()
    require'telescope'.setup {
      defaults = {
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        history = {
          path = vim.fn.expand'~/.local/share/nvim/databases/telescope_history.sqlite3',
          limit = 100,
        },
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            height = 0.90,
            width = 0.90,
            preview_width = 0.50,
            prompt_position = 'top',
          },
          vertical = {
            height = 0.90,
            width = 0.90,
            preview_height = 0.50,
            prompt_position = 'top',
          },
        },
        mappings = {
          i = {
            ['<Esc>'] = require'telescope.actions'.close,
            ['<C-Tab>'] = require'telescope.actions'.move_selection_next,
            ['<C-S-Tab>'] = require'telescope.actions'.move_selection_previous,
            ['<S-Tab>'] = require'telescope.actions'.move_selection_previous,
            ['<Tab>'] = require'telescope.actions'.move_selection_next,
            ['<M-;>'] = require'telescope.actions'.cycle_history_next,
            ['<M-j>'] = require'telescope.actions'.move_selection_next,
            ['<M-k>'] = require'telescope.actions'.move_selection_previous,
            ['<M-l>'] = require'telescope.actions'.cycle_history_prev,
          },
        },
        path_display = function(_, path)
          return vim.fn.fnamemodify(path, ':~:.')
        end,
        preview = {
          check_mime_type = true,
        },
        sorting_strategy = 'ascending',
      },
      pickers = {
        git_bcommits = {
          mappings = {
            i = {
              ['<C-Enter>'] = make_git_branch_action {
                action_name = 'Interactive git rebase',
                command = function(branch_name)
                  return { 'git', 'rbi', branch_name }
                end,
              },
            },
          },
        },
        git_commits = {
          mappings = {
            i = {
              ['<C-Enter>'] = make_git_branch_action {
                action_name = 'Interactive git rebase',
                command = function(branch_name)
                  return { 'git', 'rbi', branch_name }
                end,
              },
            },
          },
        },
        lsp_document_symbols = {
          symbols = {
            'method',
            'function',
            'class',
            'interface',
            'module',
            'enum',
            'struct',
          },
        },
      },
    }

    require'telescope'.load_extension('dap')
    require'telescope'.load_extension('fzf')
    require'telescope'.load_extension('smart_history')
  end,
}
