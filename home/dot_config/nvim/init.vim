set runtimepath+=~/.config/nvim,~/.config/nvim/lua

let &packpath = &runtimepath

""" Lua

lua require "main"

""" Autocommands

augroup conf_editor
  autocmd!
  autocmd BufEnter * checktime | let &titlestring = 'nvim - ' . expand("%:t")
  autocmd BufWritePost ~/.local/share/chezmoi/home/* lua fn.save_dot_files()
  autocmd BufWritePost * lua fn.project_check()
  autocmd ColorScheme * highlight ColorColumn guifg=darkgray ctermfg=darkgray guibg=NONE ctermbg=NONE
  autocmd ColorScheme * highlight CursorColumn gui=bold guibg=NONE ctermbg=NONE
  autocmd InsertEnter * set nocursorcolumn
  autocmd InsertLeave * set cursorcolumn
  autocmd TextChanged,TextChangedI * let b:changedtime = localtime()
  autocmd TextYankPost * lua vim.highlight.on_yank()
  autocmd WinEnter * set cursorcolumn
  autocmd WinLeave * set nocursorcolumn
augroup end

augroup conf_help
  autocmd!
  autocmd FileType help wincmd K
  autocmd FileType help nnoremap <buffer><silent> <Esc> <cmd>bdelete<CR>
augroup end

augroup conf_quickfix
  autocmd!
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

if &t_ts == "" && ( &term == "screen" || &term == "xterm" )
  let &t_ts = "\e]2;"
endif

if &t_ts != ""
  set title
endif
