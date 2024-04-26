return {
  config = function()
    local actions = require'diffview.actions'
    require'diffview'.setup {
      keymaps = {
        file_panel = {
          { 'n', [[<Down>]],         actions.select_next_entry },
          { 'n', [[<Enter>]],        actions.refresh_files },
          { 'n', [[<LeftMouse>]],    actions.select_entry },
          { 'n', [[<Up>]],           actions.select_prev_entry },
          { 'n', [[a]],              actions.toggle_stage_entry },
          { 'n', [[A]],              actions.stage_all },
          { 'n', [[j]],              actions.select_next_entry },
          { 'n', [[k]],              actions.select_prev_entry },
          { 'n', [[R]],              actions.unstage_all },
          { 'n', [[r]],              actions.restore_entry },
          { 'n', [[-]],              false },
          { 'n', [[<2-LeftMouse>]],  false },
          { 'n', [[<Tab>]],          false },
          { 'n', [[<S-Tab>]],        false },
          { 'n', [[l]],              false },
          { 'n', [[o]],              false },
          { 'n', [[S]],              false },
          { 'n', [[s]],              false },
          { 'n', [[U]],              false },
          { 'n', [[X]],              false },
        },
      },
    }
  end
}
