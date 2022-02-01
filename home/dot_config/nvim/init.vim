set runtimepath+=~/.config/nvim,~/.config/nvim/lua

let &packpath = &runtimepath

""" Lua

lua require "main"

""" Autocommands

augroup conf_editor
  autocmd!
  autocmd BufEnter * let &titlestring = 'nvim - ' . expand("%:t")
  autocmd BufEnter * checktime
  autocmd BufWritePost ~/.local/share/chezmoi/home/* lua fn.save_dot_files()
  autocmd BufWritePost * lua fn.check_project()
  autocmd CursorMoved * lua fn.highlight_cursor_text(true)
  autocmd InsertEnter,TermEnter * lua fn.highlight_cursor_text(false)
  autocmd InsertEnter * set nocursorcolumn
  autocmd InsertLeave * set cursorcolumn
  autocmd TextChanged,TextChangedI * let b:changedtime = localtime()
  autocmd TextYankPost * lua vim.highlight.on_yank()
augroup end

augroup conf_help
  autocmd!
  autocmd FileType help wincmd K
  autocmd FileType help nnoremap <buffer><silent> <Esc> <cmd>bdelete<CR>
augroup end

augroup conf_quickfix
  autocmd!
  autocmd FileType qf wincmd J
  autocmd FileType qf setlocal colorcolumn=
  autocmd FileType qf nnoremap <buffer><silent> <Esc> <cmd>quit<CR>
  autocmd VimLeavePre * cclose
augroup end

augroup conf_git
  autocmd!
  autocmd FileType gitcommit set textwidth=72
  autocmd FileType gitcommit set colorcolumn=51,73
augroup end

augroup conf_lsp
  autocmd!
  autocmd TextChangedI,TextChangedP * lua fn.trigger_completion()
  autocmd CursorMovedI * lua fn.end_completion()
augroup end
